import mysql.connector
from grakn.client import GraknClient
import multiprocessing
import datetime
import sys

uri = "localhost:48555"
keyspace = "semmed_big"


def graql_insert_sentence_query(semmed_entity, attr_type_value_to_id):
    sentence_id = semmed_entity[0]
    pmid = semmed_entity[1]
    sentence_type = semmed_entity[2]
    sentence_location = semmed_entity[3]
    sentence_start_index = semmed_entity[4]
    sentence_end_index = semmed_entity[5]
    section_header = semmed_entity[6].replace('"', "'")
    normalized_section_header = semmed_entity[7].replace('"', "'")
    sentence_text = semmed_entity[8].replace('"', "'")

    sentence_id_concept_id = attr_type_value_to_id[("sentence-id", sentence_id)]
    pmid_id = attr_type_value_to_id[("pmid", pmid)]
    sentence_type_id = attr_type_value_to_id[("sentence-type", sentence_type)]
    sentence_location_id = attr_type_value_to_id[("sentence-location", sentence_location)]
    sentence_start_index_id = attr_type_value_to_id[("sentence-start-index", sentence_start_index)]
    sentence_end_index_id = attr_type_value_to_id[("sentence-end-index", sentence_end_index)]
    section_header_id = attr_type_value_to_id[("section-header", section_header)]
    normalized_section_header_id = attr_type_value_to_id[("normalized-section-header", normalized_section_header)]
    sentence_text_id = attr_type_value_to_id[("sentence-text", sentence_text)]


    grakn_insert_query = (
        ('match $a0 id {0}; $a1 id {1}; $a2 id {2}; $a3 id {3}; $a4 id {4}; $a5 id {5}; $a6 id {6}; $a7 id {7}; $a8 id {8};' +
        'insert $s isa sentence' +
        ', has sentence-id $a0' +
        ', has pmid $a1' +
        ', has sentence-type $a2' +
        ', has sentence-location $a3' +
        ', has sentence-start-index $a4' +
        ', has sentence-end-index $a5' +
        ', has section-header $a6' +
        ', has normalized-section-header $a7' +
        ', has sentence-text $a8;').format(
            sentence_id_concept_id, pmid_id, sentence_type_id, sentence_location_id, sentence_start_index_id,
            sentence_end_index_id, section_header_id, normalized_section_header_id, sentence_text_id)
    )

    return grakn_insert_query


def grakn_insert_queries_batch_collect(queries, process_id, variable_type_value_map, attr_type_value_to_id, query_commit_batch_size=1000):
  
    with GraknClient(uri=uri) as client:
        with client.session(keyspace=keyspace) as session:
            tx = session.transaction().write()
            count = 1
            concepts_inserted = 0

            for query in queries:
                answer_iterator = tx.query(query)
                concept_map = next(answer_iterator).map()
                for variable in concept_map:
                    concept = concept_map[variable]
                    concept_id = concept.id

                    type_value = variable_type_value_map[variable]
                    if type_value in attr_type_value_to_id:
                        print("WARNING: {0} exists in ID mapping dict! From variable {1}.".format(type_value, variable))

                    attr_type_value_to_id[type_value] = concept_id
                    concepts_inserted += 1

                count += 1
                if count % query_commit_batch_size == 0:
                    tx.commit()
                    tx = session.transaction().write()
                    print("------------ Process:", process_id, "------", count, "queries commited")
            tx.commit()
            print("Cocnepts inserted in thread: {0}".format(concepts_inserted))

def grakn_insert_queries_batch(queries, process_id, query_commit_batch_size=1000):
    with GraknClient(uri=uri) as client:
        with client.session(keyspace=keyspace) as session:
            tx = session.transaction().write()
            count = 1
            for query in queries:
                try:
                    answer_iterator = tx.query(query)
                except Exception as e:
                    print(e)

                count += 1
                if count % query_commit_batch_size == 0:
                    tx.commit()
                    tx = session.transaction().write()
                    print("------------ Process:", process_id, "------", count, "queries commited")
            tx.commit()


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
        "NORMALIZED_SECTION_HEADER": "normalized-section-header",
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
    variable_type_value_mapping = {}
    counter = 0
    for attr_type, attr_value in attribute_type_pairs:
        counter += 1
        attr_value = attr_value[0]
        if type(attr_value) == str:
            attr_value = attr_value.replace('"', "'")
            queries.append('insert $x{2} "{0}" isa {1};'.format(attr_value, attr_type, counter))
        else:
            queries.append('insert $x{2} {0} isa {1};'.format(attr_value, attr_type, counter))
        variable_type_value_mapping["x{0}".format(counter)] = (attr_type, attr_value)

    return queries, variable_type_value_mapping


def split_chunks(data_list, n_chunks):
    chunks = []
    chunk_size = int(len(data_list)/n_chunks)
    for i in range(n_chunks):
        if i == n_chunks - 1:
            chunks.append(data_list[i * chunk_size:])
        else:
            chunks.append(data_list[i * chunk_size:(i + 1) * chunk_size])

    return chunks


def init(start_index, chunk_size, concurrency=None):
    start_time = datetime.datetime.now()
    end_index = int(start_index) + int(chunk_size)

    if concurrency is None:
        cpu_count = int(multiprocessing.cpu_count())
    else:
        cpu_count = int(concurrency)

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
    graql_insert_attribute_queries, variable_type_value_mapping = insert_attribute_queries(attributes_with_types)
    print("Total attribute insert queries: {0}".format(len(graql_insert_attribute_queries)))

    print("Start attribute loading...")
    attribute_load_start = datetime.datetime.now()
    query_chunks = split_chunks(graql_insert_attribute_queries, cpu_count)

    processes = []

    # create a shared map between the processes
    manager = multiprocessing.Manager()
    attr_type_value_to_id = manager.dict()

    for i in range(cpu_count):
        # batch together 5 simple attribute insert queries at once to reduce number of round trips
        chunk = query_chunks[i]
        batched_chunk = []
        batch_size = 400
        for j in range(0, len(chunk), batch_size):
            sub_chunk = chunk[j: min(len(chunk), j + batch_size)]
            merged = " ".join(sub_chunk)
            merged = merged.replace("insert", "")
            merged = "insert " + merged
            batched_chunk.append(merged)
        process = multiprocessing.Process(target=grakn_insert_queries_batch_collect, args=(batched_chunk, i, variable_type_value_mapping, attr_type_value_to_id, 5))
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
    all_queries = [graql_insert_sentence_query(sql_entity, attr_type_value_to_id) for sql_entity in sql_data]
    print("Total sentence insert queries: {0}".format(len(all_queries)))

    queries_chunks = split_chunks(all_queries, cpu_count)

    insert_sentences_start = datetime.datetime.now()
    processes = []
    print("Insert into grakn...")
    for i in range(cpu_count):
        process = multiprocessing.Process(target=grakn_insert_queries_batch, args=(queries_chunks[i], i, 500))
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
    concurrency = sys.argv[3]
    init(start_index, chunk_size, concurrency)
