export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=postgres
export POSTGRES_DB=quest_test_db
export CONTAINER=db_quest_test

export IMAGE=ankane/pgvector

docker stop $CONTAINER

docker run -it --rm --name $CONTAINER -p 5538:5432 \
  -e POSTGRES_USER=$POSTGRES_USER \
  -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
  -e POSTGRES_DB=$POSTGRES_DB \
  -v $(pwd)/dev/data_test:/var/lib/postgresql/data \
  $IMAGE
