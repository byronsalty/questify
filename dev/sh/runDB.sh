export POSTGRES_USER=quest
export POSTGRES_PASSWORD=quest
export POSTGRES_DB=quest_db
export CONTAINER=quest_db

export IMAGE=ankane/pgvector

docker run -it --rm --name $CONTAINER -p 5532:5432 \
  -e POSTGRES_USER=$POSTGRES_USER \
  -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
  -e POSTGRES_DB=$POSTGRES_DB \
  -v $(pwd)/dev/data:/var/lib/postgresql/data \
  $IMAGE
