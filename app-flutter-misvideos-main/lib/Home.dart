//import 'package:apm_pip/components/listOfApms.dart';
import 'package:apm_pip/common/httpHandler.dart';
import 'package:apm_pip/components/create.dart';
import 'package:apm_pip/components/edit.dart';
import 'package:apm_pip/components/youtubeVideoViewer.dart';
import 'package:apm_pip/models/apmModel.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:easy_pip/easy_pip.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lottie/lottie.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<List<Apm>> futureListApm$;
  bool viewFloatingActBtn = false;

  var isEnabled = false;
  var videoUrl = '';

  bool platFormWeb = false;

   @override
  void initState() {
    super.initState();
    _checkPlatform();

    futureListApm$ = HttpHandler().getAll();
    setTimer();
  }

  _checkPlatform(){
    if (kIsWeb){
      setState(() {
        platFormWeb = true;
      });
    }
  }

 //force the floatingactionBtn to appear 3 seconds later (when data has to be loaded)
  void setTimer(){
    Timer(Duration(seconds: 10), (){
      setState(() {
        viewFloatingActBtn = true;
      });  
    });
  }

  Future _reloadData(int seconds) async {
    if (seconds > 0)
      await Future.delayed(Duration(seconds: seconds));
    setState(() {
            futureListApm$ = HttpHandler().getAll();
    });
  }

  void _openCreateForm() async{
    final CreationResult result = await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => 
                CreateAPM() 
              )
    );

    if (result?.result == true){
      _reloadData(0);
       SnackBar snackbar = SnackBar(content: Text('"'+ result.apm.name + '" creado correctamente'),duration: Duration(seconds : 3));
        Scaffold.of(context).showSnackBar(snackbar);
    }
  }

  void _showDeleteConfirmation(Apm apm){
    AlertDialog dialog = new AlertDialog(
      title: ListTile(
        leading: 
          platFormWeb 
                  ? Icon(Icons.warning, size: 50,color: Colors.orangeAccent,)
                  : Lottie.asset(
                     'assets/lottie/delete.json',
                     width: 50,
                     height: 50,
                     fit : BoxFit.fill
                   ),
        title: Text('Confirmación de borrado'),
      ),
      contentPadding: EdgeInsets.all(20),
      content: Text('El vídeo con nombre "${apm.name}" se eliminará y no podrá recuperarlo. ¿Desea proceder con la eliminación?'),
      actions: [
        FlatButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancelar'),color : Colors.black26,textColor: Colors.white,),
        FlatButton(onPressed: () => _sendDelete(apm.id), child: Text('Eliminar'),color : Colors.black26,textColor: Colors.white,)
      ],
    );

    showDialog(context : context,child : dialog);
    
  }

  void _sendDelete(int id) async{
    //close dialog
    Navigator.of(context).pop();
    try{
      Apm deletedApm = await HttpHandler().delete(id);
      Scaffold.of(context).showSnackBar(
        SnackBar(content: Text('"'+ deletedApm.name + '" se ha eliminado correctamente'), duration: Duration(seconds : 3)));
      _reloadData(0);
    }catch(e){
      Scaffold.of(context).showSnackBar(
        SnackBar(content: Text(e, style: TextStyle(color: Colors.white),),backgroundColor: Colors.red[300], duration: Duration(seconds : 3)));
    }
    
  }

  void _openEditForm(Apm apm) async{
    final result = await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => 
            EditApm(apm: apm) 
          )
    );

     if (result?.result == true){
      _reloadData(0);
       SnackBar snackbar = SnackBar(content: Text('"'+ result.apm.name + '" editado correctamente'),duration: Duration(seconds : 3));
        Scaffold.of(context).showSnackBar(snackbar);
    }
  }

void _openVideoUrl(String url) async{
    setState(() {
      isEnabled = false;
    });
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
        videoUrl = url;
        isEnabled = true;
    });
}
  
  @override
  Widget build(BuildContext context) {
    return PIPStack(
        backgroundWidget:
        
         Scaffold(
            appBar: AppBar(
              title: Text('Lista de Videos'),
            ),
            body: FutureBuilder<List<Apm>>(
              future: futureListApm$,
              builder: (context,result){
                // WITH DATA
                if (result.hasData){
                  
                  return RefreshIndicator(
                    onRefresh: () => _reloadData(1),
                    strokeWidth: 4,
                    backgroundColor: Colors.grey,
                    child: 
                    ListView.builder(
                        itemCount : result.data.length,
                        itemBuilder: (context,i) =>
                        Column(
                          children : [
                            viewFloatingActBtn == false && i == 0
                            ? Padding(
                                padding: EdgeInsets.all(15),
                                child : Column(
                                  children : [
                                      platFormWeb 
                                    ? CircleAvatar(
                                        child : Icon(Icons.arrow_forward, color: Colors.white, size: 40,),
                                        backgroundColor: Colors.grey,
                                        radius : 30
                                    )
                                    : Lottie.asset(
                                        'assets/lottie/go-forward.json',
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.fill,
                                    ),
                                    Text('Mantén presionado en alguna fila para ver las operaciones disponibles',
                                      style: TextStyle(fontSize: 20),textAlign: TextAlign.center,)
                                  ])
                                )
                            : Container(),
                            i != 0 ?
                              Divider(height : 5) : Container(),
                            
                            Slidable(
                              actionPane: SlidableDrawerActionPane(),
                              actionExtentRatio: 0.25,
                              child : 
                                ListApmElement(apm : result.data[i]),
                              actions: [
                                IconSlideAction(
                                  caption: 'Ver',
                                  color: Colors.greenAccent,
                                  icon: Icons.play_arrow,
                                  onTap: () => _openVideoUrl(result.data[i].url),
                                ),
                              ],
                              secondaryActions: [
                                IconSlideAction(
                                  caption: 'Editar',
                                  color: Colors.orangeAccent,
                                  icon: Icons.edit,
                                  onTap: () => _openEditForm(result.data[i]),
                                ),
                                IconSlideAction(
                                  caption: 'Eliminar',
                                  color: Colors.redAccent,
                                  icon: Icons.delete,
                                  onTap: () => _showDeleteConfirmation(result.data[i]),
                                ),
                              ],
                            ),   
                          ]
                        )
                    ),
                  );
                  
                } else if(result.hasError){
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child : Text(result.error, style: TextStyle(fontSize: 20),textAlign: TextAlign.center,)
                    ) 
                  );
                }

                //DEFAULT
                return Center(
                    child: Container(child :  CircularProgressIndicator(),width: 50,height: 50)
                  );
              },
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: 
              viewFloatingActBtn ?
                FloatingActionButton(
                  onPressed: () => _openCreateForm(),
                  child : Icon(Icons.plus_one)
                )
              : Container()
          ),

        pipWidget: isEnabled
            ? YoutubeVideoViewer(url : videoUrl)
          : Container(),

        pipEnabled: isEnabled,
        pipShrinkHeight: platFormWeb
          ? 75
          : 130,

        onClosed: () {
          setState(() {
            isEnabled = !isEnabled;
          });
        },
      );
  }
}

class ListApmElement extends StatelessWidget {
final Apm apm;
ListApmElement({@required this.apm});

  void _demoOfSlidable(BuildContext context){
    SlidableState slidableState = Slidable.of(context);
     
    slidableState.open(actionType : SlideActionType.primary);

    Timer(Duration(milliseconds: 1500 ), (){
      slidableState.close();
      slidableState.open(actionType : SlideActionType.secondary);
    });

    Timer(Duration(milliseconds: 3000 ), (){
      slidableState.close();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Icon(
          Icons.live_tv,
          size: 40,
        ),
        title : Text(apm.name),
        contentPadding: EdgeInsets.all(10),
        subtitle: apm.desc != '' ? Text(apm.desc) : Text('Sin descripción'),
        onLongPress: () => _demoOfSlidable(context),
      );
  }
}