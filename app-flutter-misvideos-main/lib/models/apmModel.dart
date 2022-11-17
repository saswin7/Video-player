class Apm{
  int id;
  String name;
  String command;
  String desc;
  String url;
  DateTime createdAt;
  DateTime updatedAt;

  Apm({this.id,this.name,this.command,this.desc,this.url,this.createdAt,this.updatedAt});

  factory Apm.fromJson(Map<String,dynamic> json){
    return Apm(
      id : json['id'].toInt(),
      name : json['name'],
      command : json['command'],
      desc : json['desc'] ?? '',
      url : json['url'],
      createdAt: DateTime.parse( json['createdAt']),
      updatedAt: DateTime.parse( json['updatedAt']),
    );
  }

   @override
  String toString() {
    return 'APM: {id : $id, name: $name, command: $command, desc : $desc, url : $url}';
  }
}

//class creationResult - helper

class CreationResult{
  bool result;
  Apm apm;

  CreationResult({this.result,this.apm});
}

class EditionResult{
  bool result;
  Apm apm;

  EditionResult({this.result,this.apm});
}