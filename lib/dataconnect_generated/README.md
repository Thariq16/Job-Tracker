# dataconnect_generated SDK

## Installation
```sh
flutter pub get firebase_data_connect
flutterfire configure
```
For more information, see [Flutter for Firebase installation documentation](https://firebase.google.com/docs/data-connect/flutter-sdk#use-core).

## Data Connect instance
Each connector creates a static class, with an instance of the `DataConnect` class that can be used to connect to your Data Connect backend and call operations.

### Connecting to the emulator

```dart
String host = 'localhost'; // or your host name
int port = 9399; // or your port number
ExampleConnector.instance.dataConnect.useDataConnectEmulator(host, port);
```

You can also call queries and mutations by using the connector class.
## Queries

### GetJobApplicationsByUser
#### Required Arguments
```dart
String userId = ...;
ExampleConnector.instance.getJobApplicationsByUser(
  userId: userId,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetJobApplicationsByUserData, GetJobApplicationsByUserVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.getJobApplicationsByUser(
  userId: userId,
);
GetJobApplicationsByUserData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String userId = ...;

final ref = ExampleConnector.instance.getJobApplicationsByUser(
  userId: userId,
).ref();
ref.execute();

ref.subscribe(...);
```


### ListAllJobApplications
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.listAllJobApplications().execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListAllJobApplicationsData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listAllJobApplications();
ListAllJobApplicationsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.listAllJobApplications().ref();
ref.execute();

ref.subscribe(...);
```

## Mutations

### CreateJobApplication
#### Required Arguments
```dart
String userId = ...;
DateTime applicationDate = ...;
String companyName = ...;
String jobTitle = ...;
String status = ...;
ExampleConnector.instance.createJobApplication(
  userId: userId,
  applicationDate: applicationDate,
  companyName: companyName,
  jobTitle: jobTitle,
  status: status,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<CreateJobApplicationData, CreateJobApplicationVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.createJobApplication(
  userId: userId,
  applicationDate: applicationDate,
  companyName: companyName,
  jobTitle: jobTitle,
  status: status,
);
CreateJobApplicationData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String userId = ...;
DateTime applicationDate = ...;
String companyName = ...;
String jobTitle = ...;
String status = ...;

final ref = ExampleConnector.instance.createJobApplication(
  userId: userId,
  applicationDate: applicationDate,
  companyName: companyName,
  jobTitle: jobTitle,
  status: status,
).ref();
ref.execute();
```


### UpdateJobApplicationStatus
#### Required Arguments
```dart
String id = ...;
String status = ...;
ExampleConnector.instance.updateJobApplicationStatus(
  id: id,
  status: status,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<UpdateJobApplicationStatusData, UpdateJobApplicationStatusVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.updateJobApplicationStatus(
  id: id,
  status: status,
);
UpdateJobApplicationStatusData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;
String status = ...;

final ref = ExampleConnector.instance.updateJobApplicationStatus(
  id: id,
  status: status,
).ref();
ref.execute();
```

