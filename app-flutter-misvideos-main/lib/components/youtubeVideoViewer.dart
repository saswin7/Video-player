import 'package:apm_pip/common/httpHandler.dart';
import 'package:flutter/material.dart';
import 'package:ext_video_player/ext_video_player.dart';
import 'package:apm_pip/models/apmModel.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

class YoutubeVideoViewer extends StatefulWidget {
  final url;
  YoutubeVideoViewer({@required this.url});

  @override
  _YoutubeVideoViewerState createState() => _YoutubeVideoViewerState(url : url);
}

class _YoutubeVideoViewerState extends State<YoutubeVideoViewer> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  VideoPlayerController _controller;
  String url;

  bool dataLoaded = false;
  List<Apm> apmList;

  bool platFormWeb = false;

  _YoutubeVideoViewerState({@required this.url});

 
  @override
  void initState() {
    super.initState();
      _checkPlatform();
      loadApms();
      
      _controller = VideoPlayerController.network(
        url
      );
        //print(url);
      _controller.addListener(() {
        setState(() {});
      });
      _controller.setLooping(true);
      _controller.initialize().catchError((e) => onError(e));
    
  }

  _checkPlatform(){
    if (kIsWeb){
      setState(() {
        platFormWeb = true;
      });
    }
  }

  void loadApms() async{
    try {
      List<Apm> data = await HttpHandler().getAll();
      setState((){
        apmList = data;
        dataLoaded = true;
      });
    } catch (e) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(e, style: TextStyle(color: Colors.white),),backgroundColor: Colors.red[300]));
    }
  }

  void onError(error){
    //print(error.code);
      //show error
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(error.code, style: TextStyle(color: Colors.white),),backgroundColor: Colors.red[300]));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _changeUrl(String videoUrl){
    setState(() {
        _controller.pause();

        url = videoUrl;
        
        _controller = VideoPlayerController.network(
            url
        );

        _controller.addListener(() {
          setState(() {});
        });
        _controller.setLooping(true);
        _controller.initialize().catchError((e) => onError(e));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      key : _scaffoldKey,
      body: Column(
        children: <Widget>[
          Container(
            child: AspectRatio(
              aspectRatio: 
                platFormWeb
                ? 3
                : _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  VideoPlayer(_controller),
                  ClosedCaption(text: _controller.value.caption.text),
                  _PlayPauseOverlay(controller: _controller),
                  VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child  : 
              dataLoaded == false 
                ? Center(
                    child: Container(child :  CircularProgressIndicator(),width: 50,height: 50)
                  )
                : ListView.builder(
                  itemCount: apmList.length,
                  itemBuilder: (context,i) =>
                    Column(
                      children : [
                        i != 0 ? Divider(height: 3) : Container(),
                        ListTile(
                          contentPadding: EdgeInsets.all(5),
                          leading : Icon(Icons.play_arrow, size : 30),
                          title : Text(apmList[i].name),
                          onTap: () => _changeUrl(apmList[i].url),
                        )
                      ]
                    )
                    
                )
          )
         
        ],
      ),
    );
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  const _PlayPauseOverlay({Key key, this.controller}) : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}