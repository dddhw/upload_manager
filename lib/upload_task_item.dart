///上传任务item

class UploadTaskItem {
  ///android平台只需要path路径 ios平台需要filename和bytesData
  String path;   ///文件路径
  String fileName; ///文件名
  String category;  ///服务器文件目录
  List<int> bytesData; ///二进制数据

  UploadTaskItem({this.path, this.fileName, this.category, this.bytesData});
}