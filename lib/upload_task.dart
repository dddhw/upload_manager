///上传任务

import 'package:dio/dio.dart';

import 'upload_task_item.dart';

class UploadTask{

  CancelToken cancelToken; ///取消令牌
  List<UploadTaskItem> tasks; ///上传任务

  UploadTask() {
    cancelToken = CancelToken();
  }
}