import 'package:flutter/material.dart';
import 'package:apm_pip/models/apmModel.dart';
import 'package:apm_pip/common/httpHandler.dart';
import 'package:lottie/lottie.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

class CreateAPM extends StatefulWidget {
  @override
  _CreateAPMState createState() => _CreateAPMState();
}

class _CreateAPMState extends State<CreateAPM> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Apm apm = new Apm(
      id: 0,
      name: '',
      command: '',
      desc: '',
      url : '',
      createdAt: new DateTime.now(),
      updatedAt: new DateTime.now()
    );

  TextEditingController _nameController = new TextEditingController();
  TextEditingController _descController = new TextEditingController();
  TextEditingController _commandController = new TextEditingController();
  TextEditingController _urlController = new TextEditingController();

  bool platFormWeb = false;
  
  _checkPlatform(){
    if (kIsWeb){
      setState(() {
        platFormWeb = true;
      });
    }
  }

  @override
  void initState() { 
    super.initState();

    _checkPlatform();
  }

  void _sendPost(Apm apm) async{
   Apm apmCreated;
    try{
      apmCreated = await HttpHandler().create(apm);
      //pop con data de vuelta - para hacer el reload
      Navigator.of(context).pop(CreationResult(result : true, apm : apmCreated));
    } catch(error){    
        //print(error);
      SnackBar snackbar = SnackBar(content: Text(error, style: TextStyle(color: Colors.white),),backgroundColor: Colors.red[300], duration: Duration(seconds : 3));
     _scaffoldKey.currentState.showSnackBar(snackbar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
       appBar: AppBar(
        title: Text('Crear'),
      ),
      body : Center(
        child : ListView(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical : 30, horizontal: 50),
          children: [
             Column(
                 children: [
                      platFormWeb 
                    ? CircleAvatar(
                        child : Icon(Icons.plus_one, color: Colors.white, size: 40,),
                        backgroundColor: Colors.grey,
                        radius : 30
                    )
                    : Lottie.asset(
                        'assets/lottie/add.json',
                        width: 100,
                        height: 100,
                        fit : BoxFit.fill
                   ),
                    TextField(
                      decoration: InputDecoration(hintText: 'Nombre *'),
                      controller : _nameController,
                      onChanged : (String value) => setState((){ apm.name = value; }),
                    ),
                    TextField(
                      decoration: InputDecoration(hintText: 'Nombre corto *'),
                      controller : _commandController,
                      onChanged : (String value)=> setState((){apm.command = value;}),
                    ),
                    TextField(
                      decoration: InputDecoration(hintText: 'Descripción'),
                      controller : _descController,
                      onChanged : (String value)=> setState((){apm.desc = value;}),
                    ),
                    TextField(
                      decoration: InputDecoration(hintText: 'URL *'),
                      controller : _urlController,
                      onChanged : (String value)=> setState((){apm.url = value;}),
                    ),
                    Padding(padding: EdgeInsets.only(bottom : 15)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        RaisedButton(
                            disabledColor : Colors.white70,
                            color : Colors.black26,
                            onPressed: () => Navigator.of(context).pop(CreationResult(result : false, apm : null)), child: Text('Cancelar')),
                         RaisedButton(
                            disabledColor : Colors.white70,
                            color : Colors.black26,
                            onPressed: () => _sendPost(apm),
                            child: Text('Crear'))
                      ],
                    )
                 ],
               ), 
          ],
      ),
      )
    );
  }
}