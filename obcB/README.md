# obcB Application

This deployment was auto-generated by the F' utility tool.

## Building and Running the obcB Application

In order to build the obcB application, or any other F´ application, we first need to generate a build directory. This can be done with the following commands:

```
cd obcB
fprime-util generate
```

The next step is to build the obcB application's code.
```
fprime-util build
```

## Running the application and F' GDS

The following command will spin up the F' GDS as well as run the application binary and the components necessary for the GDS and application to communicate.

```
cd obcB
fprime-gds
```

To run the ground system without starting the obcB app:
```
cd obcB
fprime-gds --no-app
```

The application binary may then be run independently from the created 'bin' directory.

```
cd obcB/build-artifacts/<platform>/bin/
./obcB -a 127.0.0.1 -p 50000
```
