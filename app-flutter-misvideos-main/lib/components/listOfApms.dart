import 'package:apm_pip/common/httpHandler.dart';
import 'package:apm_pip/components/create.dart';
import 'package:apm_pip/components/edit.dart';
import 'package:apm_pip/models/apmModel.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_slidable/flutter_slidable.dart';

class ListOfApms extends StatefulWidget {
  @override
  _ListOfApmsState createState() => _ListOfApmsState();
}

class _ListOfApmsState extends State<ListOfApms> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Future<List<Apm>> futureListApm$;
  bool viewFloatingActBtn = false;

  @override
  void initState() {
    super.initState();

    futureListApm$ = HttpHandler().getAll();
    setTimer();
  }

 //force the floatingactionBtn to appear 3 seconds later (when data has to be loaded)
  void setTimer(){
    Timer(Duration(seconds: 3), (){
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
       _scaffoldKey.currentState.showSnackBar(snackbar);
    }
  }

  void _showDeleteConfirmation(BuildContext ctx, Apm apm){
    AlertDialog dialog = new AlertDialog(
      title: ListTile(
        leading: Icon(Icons.warning,color: Colors.orangeAccent,),
        title: Text('Confirmación de borrado'),
      ),
      contentPadding: EdgeInsets.all(20),
      content: Text('El APM con nombre "${apm.name}" se eliminará y no podrá recuperarlo. ¿Desea proceder con la eliminación?'),
      actions: [
        FlatButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancelar'),color : Colors.black26,textColor: Colors.white,),
        FlatButton(onPressed: () => _sendDelete(ctx, apm.id), child: Text('Eliminar'),color : Colors.black26,textColor: Colors.white,)
      ],
    );

    showDialog(context: ctx,child : dialog);
    
  }

  void _sendDelete(BuildContext ctx,int id) async{
    //close dialog
    Navigator.of(context).pop();
    try{
      Apm deletedApm = await HttpHandler().delete(id);
      Scaffold.of(ctx).showSnackBar(
        SnackBar(content: Text('"'+ deletedApm.name + '" se ha eliminado correctamente'), duration: Duration(seconds : 3)));
      _reloadData(0);
    }catch(e){
      Scaffold.of(ctx).showSnackBar(
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
       _scaffoldKey.currentState.showSnackBar(snackbar);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Lista de APMs'),
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
                          child : Text('Mantén presionado en alguna fila para ver las operaciones disponibles',style: TextStyle(fontSize: 20),textAlign: TextAlign.center,))
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
                            onTap: () => print(result.data[i].name + ' > ' + result.data[i].url),
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
                            onTap: () => _showDeleteConfirmation(context, result.data[i]),
                          ),
                        ],
                      ),   
                    ]
                  )
              ),
            );
            
          } else if(result.hasError){
            /*// ERROR
             var snackbar = SnackBar(content: Text(result.error));
            Scaffold.of(context).showSnackBar(snackbar);
             return Center(
               child: Container(child :  CircularProgressIndicator(),width: 50,height: 50)
             );*/
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
    );
  }
}

class ListApmElement extends StatelessWidget {
Apm apm;
ListApmElement({this.apm});

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
          size: 50,
        ),
        title : Text(apm.name),
        subtitle: apm.desc != '' ? Text(apm.desc) : Text('Sin descripción'),
        onLongPress: () => _demoOfSlidable(context),
      );
  }
}