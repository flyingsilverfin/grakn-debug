import mysql.connector
from grakn.client import GraknClient
import multiprocessing
import datetime
import sys

uri = "localhost:48555"
keyspace = "semmed_big"


def graql_insert_sentence_query(semmed_entity):
    sentence_id = semmed_entity[0]
    pmid = semmed_entity[1]
    sentence_type = semmed_entity[2]
    sentence_location = semmed_entity[3]
    sentence_start_index = semmed_entity[4]
    sentence_end_index = semmed_entity[5]
    section_header = semmed_entity[6].replace('"', "'")
    normalized_section_header = semmed_entity[7].replace('"', "'")
    sentence_text = semmed_entity[8].replace('"', "'")


    grakn_insert_query = (
        'insert '
        '$s isa sentence, has sentence-id ' + str(sentence_id) +
        ', has pmid \"' + str(pmid) + "\""
        ', has sentence-type \"' + str(sentence_type) + '\"'
        ', has sentence-location ' + str(sentence_location) +
        ', has sentence-start-index ' + str(sentence_start_index) +
        ', has sentence-end-index ' + str(sentence_end_index) +
        ', has section-header \"' + str(section_header) + '\"' 
        ', has normalized-section-header \"' + str(normalized_section_header) + '\"'
        ', has sentence-text \"' + str(sentence_text) + '\"'
        ';')

    return grakn_insert_query


def grakn_insert_queries_batch(queries, process_id, query_commit_batch_size=1000):
    with GraknClient(uri=uri) as client:
        with client.session(keyspace=keyspace) as session:
            tx = session.transaction().write()
            for index, query in enumerate(queries):
                tx.query(query)
                if index % query_commit_batch_size == 0:
                    tx.commit()
                    tx = session.transaction().write()
                    print("------------ Process:", process_id, "------", index, "data commited")
            tx.commit()


def load_to_grakn(sentences_list, process_id):
    with GraknClient(uri=uri) as client:
        with client.session(keyspace=keyspace) as session:
            tx = session.transaction().write()

            iterator = 1
            for entity in sentences_list:
                query = graql_insert_sentence_query(entity)
                tx.query(query)

                iterator += 1

                if iterator % 1000 == 0:
                    tx.commit()
                    tx = session.transaction().write()
                    print("------------ Process:", process_id, "------", iterator, "data commited")


"""
From the SQL DB, between the start and end index, 
flatten all the attributes into a list of pairs:
[grakn attribute type, attribute value]
where the attribute values are unique per type
"""
def fetch_unique_attributes(mydb, start_index, end_index):
    cursor = mydb.cursor()

    attributes = []

    sql_to_grakn_attributes = {
        "SENTENCE_ID": "sentence-id",
        "PMID": "pmid",
        "TYPE": "sentence-type",
        "NUMBER": "sentence-location",
        "SENT_START_INDEX": "sentence-start-index",
        "SENT_END_INDEX": "sentence-end-index",
        "SECTION_HEADER": "section-header",
        "NORMALIZED_SECTION_HEADER": "normalised-section-header",
        "SENTENCE": "sentence-text"
    }

    sql_attr_query = "SELECT DISTINCT {0} FROM SENTENCE WHERE SENTENCE_ID < " + str(end_index) + " AND SENTENCE_ID >= " + str( start_index) + ";"
    for sql_attribute in sql_to_grakn_attributes:

        grakn_attribute_type = sql_to_grakn_attributes[sql_attribute]

        sql_query = sql_attr_query.format(sql_attribute)
        print(sql_query)

        cursor.execute(sql_query)
        unique_attributes = cursor.fetchall()

        for unique_attribute in unique_attributes:
            attributes.append((grakn_attribute_type, unique_attribute))

    return attributes


def insert_attribute_queries(attribute_type_pairs):
    queries = []
    for attr_type, attr_value in attribute_type_pairs:
        attr_value = attr_value[0]
        if type(attr_value) == str:
            queries.append('insert $x "{0}" isa {1};'.format(attr_value, attr_type))
        else:
            queries.append('insert $x {0} isa {1};'.format(attr_value, attr_type))

    return queries


def split_chunks(data_list, chunk_size):
    chunks = []
    n_chunks = int((len(data_list) - 1)/chunk_size) + 1
    for i in range(n_chunks):
        if i == n_chunks - 1:
            chunks.append(data_list[i * chunk_size:])
        else:
            chunks.append(data_list[i * chunk_size:(i + 1) * chunk_size])

    return chunks


def init(start_index, chunk_size):
    start_time = datetime.datetime.now()
    end_index = int(start_index) + int(chunk_size)
    cpu_count = multiprocessing.cpu_count()
    print("start_index: " + str(start_index))
    print("chunk_size: " + str(chunk_size))
    print("end_index: " + str(end_index))
    print("concurrency: " + str(cpu_count))

    # max index 286 954 861
    # max index 332 724 280

    ########GET DATA FROM DB

    mydb = mysql.connector.connect(
        host="localhost",
        user="grakn",
        passwd="password",
        database="semmed",
        auth_plugin='mysql_native_password'
    )

    # Get deduplicated attributes and insert them in parallel
    print("Fetching unique attributes from sql...")
    attributes_with_types = fetch_unique_attributes(mydb, start_index, end_index)
    print("Creating insert attribute queries...")
    graql_insert_attribute_queries = insert_attribute_queries(attributes_with_types)

    print("Start attribute loading...")
    attribute_load_start = datetime.datetime.now()
    chunk_size = int(len(graql_insert_attribute_queries) / cpu_count)
    query_chunks = split_chunks(graql_insert_attribute_queries, chunk_size)
    processes = []
    for i in range(cpu_count):
        process = multiprocessing.Process(target=grakn_insert_queries_batch, args=(query_chunks[i], i))
        process.start()
        processes.append(process)

    for process in processes:
        process.join()

    attribute_load_finish = datetime.datetime.now()
    print("Finished loading attributes\n")

    # Create entities and ownerships of attributes
    print("Getting all rows from db...")
    mycursor = mydb.cursor()
    mycursor.execute("SELECT * FROM SENTENCE WHERE SENTENCE_ID <" + str(end_index) + " AND SENTENCE_ID >= " + str(start_index))
    sql_data = mycursor.fetchall()
    print("Creating graql insert queries...")
    all_queries = [graql_insert_sentence_query(sql_entity) for sql_entity in sql_data]

    chunk_size = int(len(all_queries) / cpu_count)
    queries_chunks = split_chunks(all_queries, chunk_size)

    insert_sentences_start = datetime.datetime.now()
    processes = []
    for i in range(cpu_count):
        process = multiprocessing.Process(target=grakn_insert_queries_batch, args=(queries_chunks[i], i))
        process.start()
        processes.append(process)

    for process in processes:
        process.join()

    end_time = datetime.datetime.now()

    print("- - - - - -")

    print("SQL attribute deduplicate and graql query creation time: {0}".format(attribute_load_start - start_time))
    print("Attribute Load Time: {0}".format(attribute_load_finish - attribute_load_start))
    print("SQL sentences load time and graql query creation time: {0}".format(insert_sentences_start - attribute_load_finish))
    print("Sentence Load Time: {0}".format(end_time - insert_sentences_start))
    print("==> Total Time taken: {0}".format(end_time - start_time))


if __name__ == "__main__":
    start_index = sys.argv[1]
    chunk_size = sys.argv[2]
    init(start_index, chunk_size)
