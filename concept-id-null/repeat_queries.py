from grakn.client import GraknClient
import random
import string

def define_schema(session):
    with session.transaction().write() as tx:
        tx.query("define "
             "person sub entity, plays friend, has name;"
             "friendship sub relation, relates friend, has n;"
             "name sub attribute, datatype string;"
             "n sub attribute, datatype long;")
        tx.commit()

def random_string(size=6, chars=string.ascii_uppercase + string.digits):
    return ''.join(random.choice(chars) for _ in range(size))

def random_number():
    return random.randint(0, 1e10)

def single_insert(session):
    with session.transaction().write() as tx:
        name1 = random_string()
        name2 = random_string()
        n = random_number()
        tx.query("insert $x isa person, has name \"{0}\"; $y isa person, has name \"{1}\"; $r (friend: $x, friend: $y) isa friendship, has n {2};".format(name1, name2, n))
        tx.commit()


def multiple_insert(session, n=50):
    for i in range(n):
        single_insert(session)


def run_test(keyspace):
    print("Creating client and keyspace: " + keyspace)
    client = GraknClient("localhost:48555")
    session = client.session(keyspace=keyspace)

    print("Creating schema...")
    define_schema(session)

    for i in range(20):
        print("Write + Read iteration {0}".format(i))
        multiple_insert(session, n=50)

        with session.transaction().write() as tx:
            # query for everything
            conceptMaps = list(tx.query("match $x isa thing; get;"))
            print("retreived {0} answers".format(len(conceptMaps)))

            # query for concepts, then ask for attrs
            attrs = 0
            for conceptMap in conceptMaps:
                for a in conceptMap.get("x").attributes():
                    attrs += 1
            print("Retreived {0} attributes".format(attrs))


for i in range(200):
    keyspace = "test_1_{0}".format(i)
    run_test(keyspace)