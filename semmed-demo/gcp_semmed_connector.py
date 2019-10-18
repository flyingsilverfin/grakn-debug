import mysql.connector
from grakn.client import GraknClient
import multiprocessing
import datetime
import collections
import sys

uri = "localhost:48555"
keyspace = "semmed_big"


def get_sentence_query(semmed_entity):

    sentence_id = ""
    pmid = ""
    sentence_type = ""
    sentence_location = ""
    sentence_start_index = ""
    sentence_end_index = ""
    section_header = ""
    normalized_section_header = ""
    sentence_text = ""

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
    
    #print(grakn_insert_query)

    return grakn_insert_query


def load_to_grakn(sentences_list, process_id):
    with GraknClient(uri=uri) as client:
        with client.session(keyspace=keyspace) as session:
            tx = session.transaction().write()

            iterator = 1
            for entity in sentences_list:
                query = get_sentence_query(entity)
                tx.query(query)

                

                iterator += 1

                if iterator % 400 == 0:
                    tx.commit()
                    tx = session.transaction().write()
                    print("------------ Process:", process_id, "------", iterator, "data commited")

def init(start_index, chunk_size, concurrency=None):

    start_time = datetime.datetime.now()
    end_index = int(start_index) + int(chunk_size)
    print("start_index: " + str(start_index))
    print("chunk_size: " + str(chunk_size))
    print("end_index: " + str(end_index))

    #max index 286 954 861
    #max index 332 724 280


########GET DATA FROM DB

    mydb = mysql.connector.connect(
        host="localhost",
        user="grakn",
        passwd="password",
        database="semmed",
        auth_plugin='mysql_native_password'
    )

    mycursor = mydb.cursor()

    mycursor.execute("SELECT * FROM SENTENCE WHERE SENTENCE_ID <" + str(end_index) + " AND SENTENCE_ID >= " + str(start_index))

    #"SELECT * FROM PREDICATION LIMIT 10")
    #SELECT COUNT(DISTINCT SENTENCE_ID) FROM SENTENCE WHERE SENTENCE_ID < 1000

    sqlData = mycursor.fetchall()
    



    ########UPLOAD DATA TO GRAKN
    ##Time taken: 0:10:12.904031 --- normal upload
    ##Time taken: 0:06:21.762559 --- concurrent upload
    ##Time taken: 0:07:04.345103 --- Cython upload

    #    load_to_grakn(sqlData)


    ####concurrent load
    if concurrency is None:
        cpu_count = multiprocessing.cpu_count()
    else:
        cpu_count = int(concurrency)
    #cpu_count = 1

    chunk_size = int(len(sqlData)/cpu_count)

    print("sql size: " + str(len(sqlData)))
    print("chunk size: " + str(chunk_size))

    processes = []

    for i in range(cpu_count):
        

        if i == cpu_count - 1:
            chunk = sqlData[i*chunk_size:]
        else:
            chunk = sqlData[i*chunk_size:(i+1) * chunk_size]

        process = multiprocessing.Process(target = load_to_grakn, args = (chunk, i))
    
        process.start()
        processes.append(process)

    
    for process in processes:
        process.join()

    end_time = datetime.datetime.now()

    print("sql size: " + str(len(sqlData)))
    print("- - - - - -\nTime taken: " + str(end_time - start_time))


if __name__ == "__main__":
    start_index = sys.argv[1]
    chunk_size = sys.argv[2]
    concurrency = sys.argv[3]
    init(start_index, chunk_size, concurrency)

