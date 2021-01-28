///
///
///     上传管理器
///
///     dhw 2021-01-29
///     example
///
///     String url = 'https://test.com/api/upload/uploadFile';
///     Map<String, String> header = Map();
///     header['Authorization'] = 'Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIxXHUwMDA3Kzg2MTcwMDAwMDAwMDAiLCJjcmVhdGVkIjoxNjExODEyMzA5OTk4LCJleHAiOjE2MTI0MTcxMDl9.DRcxMZCR8U55GuYRIQrqoa-XjoFIYDzO8FA7UQISAncwgzQTtCYdzQE8rkHIKkJasy9OADoj6x20A5JIQrXfWA';
///
///     UploadTask uploadTask = new UploadTask();
///
///     uploadTask.tasks = tasks;
///
///
///     uploadManager = UploadManager(url, header: header);
///     uploadManager.upload(uploadTask);
///
///     事件通知
///
///     uploadManagerEventBus.on<UploadEvent>().listen((e){
///       if(e.eventType == UploadEventType.change_progress) {
///
///       } else if (e.eventType == UploadEventType.upload_cancel) {
///
///       } else if (e.eventType == UploadEventType.upload_finish) {
///
///       } else if (e.eventType == UploadEventType.upload_fail) {
///
///       }
///
///      取消任务
///
///      uploadManager.cancel(uploadTask);
///

library upload_manager;


import 'package:upload_manager/upload_result.dart';

import 'upload_task_item.dart';
import 'upload_event.dart';
import 'upload_task.dart';
import 'package:dio/dio.dart';
import 'package:event_bus/event_bus.dart';


EventBus uploadManagerEventBus = new EventBus();


class UploadManager {


  String url; ///上传url
  Map<String, String> header; ///header
  int _uploadTimeOut = 30 * 1000; ///上传超时
  int _connectTimeOut = 10 * 1000; ///连接超时


  UploadManager(this.url , {this.header});

  /*
   * 下载单个任务
   */
  upload(UploadTask uploadTask) async {

    if (uploadTask == null || uploadTask.tasks == null || uploadTask.tasks.length == 0) {
      return;
    }


    List<UploadResult> results = List();
    for (int i=0;i<uploadTask.tasks.length;i++) {

      // print('upload task =' + i.toString());

      UploadTaskItem task = uploadTask.tasks[i];

      FormData formData;
      if (task.path != null) {
        formData = FormData.fromMap({
          "category": task.category,
          "file": await MultipartFile.fromFile(task.path),
          });
      } else if (task.bytesData != null) {
        formData = FormData.fromMap({
          "category": task.category,
          "file": MultipartFile.fromBytes(task.bytesData, filename: task.fileName),
        });
        // header['content-length'] = task.bytesData.length.toString();
      }




      try {

        RequestOptions options = RequestOptions(headers: header, sendTimeout: _uploadTimeOut, connectTimeout: _connectTimeOut);
        options.headers.remove('content-length');
        Response response = await Dio().post(url, data: formData,
            options: options,
            cancelToken: uploadTask.cancelToken,
            onSendProgress: (int count, int total) {
              ///发送上传进度变更事件
              uploadManagerEventBus.fire(UploadEvent(UploadEventType.change_progress,
                  totalUploadFileCount: uploadTask.tasks.length,
                  uploadedFileCount: i + 1,
                  currUploadFileTotalSize: total,
                  currUploadedFileSize: count));
              // print('total=$total count=$count');
            });

        // print(response.toString());


        ///当为200时 组装返回值
        if (response.statusCode == 200){

          UploadResult result = new UploadResult(response.data['data']);
          results.add(result);

          ///当最后一个上传完成后发送完成事件
          if (i == uploadTask.tasks.length - 1) {
            uploadManagerEventBus.fire(UploadEvent(UploadEventType.upload_finish, uploadResults: results));
          } else {
            uploadManagerEventBus.fire(UploadEvent(UploadEventType.change_progress,
                totalUploadFileCount: uploadTask.tasks.length,
                uploadedFileCount: i+1, currUploadedFileSize: 0, currUploadFileTotalSize: 0));
          }
       }

      } catch(e) {
        if (e is DioError) {
          if (e.type == DioErrorType.CANCEL){
            //todo 是否要发送取消事件？
            break;
          } else {
            ///上传失败 发送失败事件
            uploadManagerEventBus.fire(UploadEvent(UploadEventType.upload_fail));
            break;
          }
        }
        print(e.toString());
      }

    }


  }

  /*
   * 取消下载任务
   */
  cancel(UploadTask uploadTask) {
    if (uploadTask.cancelToken != null) {
      uploadTask.cancelToken.cancel('cancel task');
      if (uploadManagerEventBus != null) {
        uploadManagerEventBus.fire(UploadEvent(UploadEventType.upload_cancel));
      }
    }
  }

}
