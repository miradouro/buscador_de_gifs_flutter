import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:transparent_image/transparent_image.dart';
import 'gif_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String _search = '';

  int _offset = 0;

  Future<Map>_getGifs() async {
    http.Response response;

    if(_search == '')
      response = await http.get(Uri.parse("https://api.giphy.com/v1/gifs/trending?api_key=OgUtjAFvlKbAd8tWGSt964KQ7gSN9Hyy&limit=20&rating=g"));
    else
      response = await http.get(Uri.parse("https://api.giphy.com/v1/gifs/search?api_key=OgUtjAFvlKbAd8tWGSt964KQ7gSN9Hyy&q=$_search&limit=19&offset=$_offset&rating=g&lang=pt"));

    return json.decode(response.body);

  }

  @override
  void initState() {
    super.initState();
    _getGifs().then((map){

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network("https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Pesquise Aqui!",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2),),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2),),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2),),
              ),
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
              onSubmitted: (text){
                setState((){
                  _search = text;
                  _offset = 0;
                });
              },

            ),
          ),
          Expanded(
              child: FutureBuilder(
                future: _getGifs(),
                builder: (context, snapshot) {
                  switch(snapshot.connectionState){
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200,
                        height: 200,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5,
                        ),
                      );
                    default:
                      if(snapshot.hasError)return Container();
                      else return _createGifTable(context, snapshot);
                  }
                },
              ),
          ),
        ],
      )
    );
  }

  int _getCount(List data){
    if(_search == ''){
      return data.length;
    }else{
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot){
    return GridView.builder(
      padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _getCount(snapshot.data["data"]),
        itemBuilder: (context, index){
          if(_search == '' || index < snapshot.data["data"].length)
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                  height: 300,
                  fit: BoxFit.cover,
              ),
              onTap: (){
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => GifPage(snapshot.data["data"][index]))
                );
              },
              onLongPress: (){
                Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
              },
            );
          else
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.add, color: Colors.white,size: 70,),
                    Text("Carregar mais...", style: TextStyle(color: Colors.white, fontSize: 22,),)
                  ],
                ),
                onTap: (){
                  setState((){
                    _offset += 19;
                  });
                },
              ),
            );
        }
    );
  }
}
