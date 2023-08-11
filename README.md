docker build -t sneumann/nmrml-validator .

docker run --rm -it -v $PWD/OpenMS:/OpenMS sneumann/nmrml-validator bash


