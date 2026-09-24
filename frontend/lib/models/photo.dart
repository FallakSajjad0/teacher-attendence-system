class Photo {
  final String id,url,filename,verificationStatus;
  Photo({required this.id,required this.url,required this.filename,required this.verificationStatus});
  factory Photo.fromJson(Map<String,dynamic> j)=>Photo(id:'${j['id']??''}',url:'${j['url']??''}',filename:'${j['filename']??''}',verificationStatus:'${j['verification_status']??'pending'}');
}
