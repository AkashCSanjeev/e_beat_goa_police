import 'package:flutter/material.dart';





class ext_tile_form extends StatefulWidget {
  const ext_tile_form({Key? key}) : super(key: key);

  @override
  _ext_tile_formState createState() => _ext_tile_formState();
}

class _ext_tile_formState extends State<ext_tile_form> {
  final List<Map<String, dynamic>> _items = List.generate(
      8,
          (index) => {
        "id": index,
        "title": " $index  ",
        "content":
        "This is the main content of item $index. It is very long and you have to expand the tile to see it."


      });



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Locations')),
        body: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (_, index) {
              final item = _items[index];
              return Card(
                key: PageStorageKey(item['id']),
                color: Colors.blue,
                elevation: 4,
                child: ExpansionTile(
                    iconColor: Colors.white,
                    collapsedIconColor: Colors.white,
                    childrenPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    expandedCrossAxisAlignment: CrossAxisAlignment.end,
                    title: Text(item['title'], style: const TextStyle(
                        color: Colors.white
                    ),),
                    children: [
                      Text(item['content'], style: const TextStyle(
                          color: Colors.white
                      )),
                      // This button is used to remove this item
                       Row(mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Padding(
                             padding: const EdgeInsets.all(12.0),
                             child: FloatingActionButton.extended(

                               label: Text('Report'),
                               icon: Icon(Icons.edit),
                               onPressed: () {  },
                               backgroundColor: Colors.red,
                               foregroundColor: Colors.white,
                             ),
                           ),
                           Padding(
                             padding: const EdgeInsets.all(12.0),
                             child: FloatingActionButton.extended(

                               label: Text('All Good!'),
                               icon: Icon(Icons.thumb_up),
                               onPressed: () {  },
                               backgroundColor: Colors.green,
                               foregroundColor: Colors.white,
                             ),
                           ),
                         ],
                       ),
                    ]
                ),
              );
            })
    ,
    floatingActionButton: FloatingActionButton.large(
    onPressed: (){},
    child: Text('+'),
    backgroundColor: Colors.blue[800]
    ));
  }
}
