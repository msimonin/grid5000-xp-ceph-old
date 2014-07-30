import boto
import boto.s3.connection
access_key = '12345'
secret_key = '12345'

conn = boto.connect_s3(
        aws_access_key_id = access_key,
        aws_secret_access_key = secret_key,
        host = 'localhost',
        is_secure=False,               # uncommmnt if you are not using ssl
        calling_format = boto.s3.connection.OrdinaryCallingFormat(),
)

bucket = conn.create_bucket('my-new-bucket')

print "bucket list"
for bucket in conn.get_all_buckets():
        print "{name}\t{created}".format(
                name = bucket.name,
                created = bucket.creation_date,
        )

print "add a file to the bucket"
key = bucket.new_key('hello.txt')
key.set_contents_from_string('Hello World!')


print "list of keys in the bucket"
for key in bucket.list():
        print "{name}\t{size}\t{modified}".format(
                name = key.name,
                size = key.size,
                modified = key.last_modified,
                )
