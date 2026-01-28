library dataconnect_generated;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'create_job_application.dart';

part 'get_job_applications_by_user.dart';

part 'update_job_application_status.dart';

part 'list_all_job_applications.dart';







class ExampleConnector {
  
  
  CreateJobApplicationVariablesBuilder createJobApplication ({required String userId, required DateTime applicationDate, required String companyName, required String jobTitle, required String status, }) {
    return CreateJobApplicationVariablesBuilder(dataConnect, userId: userId,applicationDate: applicationDate,companyName: companyName,jobTitle: jobTitle,status: status,);
  }
  
  
  GetJobApplicationsByUserVariablesBuilder getJobApplicationsByUser ({required String userId, }) {
    return GetJobApplicationsByUserVariablesBuilder(dataConnect, userId: userId,);
  }
  
  
  UpdateJobApplicationStatusVariablesBuilder updateJobApplicationStatus ({required String id, required String status, }) {
    return UpdateJobApplicationStatusVariablesBuilder(dataConnect, id: id,status: status,);
  }
  
  
  ListAllJobApplicationsVariablesBuilder listAllJobApplications () {
    return ListAllJobApplicationsVariablesBuilder(dataConnect, );
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'us-east4',
    'example',
    'jobtracker',
  );

  ExampleConnector({required this.dataConnect});
  static ExampleConnector get instance {
    return ExampleConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}
