///上传事件

import 'package:upload_manager/upload_result.dart';

enum UploadEventType{
  change_progress, ///进度变更
  upload_finish, ///下载完成
  upload_cancel,  ///取消下载
  upload_fail ///下载失败
}

class UploadEvent{

  int totalUploadFileCount; ///上传文件总数
  int uploadedFileCount; ///已经上传文件个数
  int currUploadFileTotalSize; ///当前上传文件的大小
  int currUploadedFileSize; ///当前上传文件已经上传的大小
  List<UploadResult> uploadResults; ///上传结果

  UploadEventType eventType;

  UploadEvent(this.eventType ,{this.totalUploadFileCount, this.uploadedFileCount,
    this.currUploadFileTotalSize, this.currUploadedFileSize, this.uploadResults});
}