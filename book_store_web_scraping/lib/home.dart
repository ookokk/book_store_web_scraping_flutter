import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'book.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var url = Uri.parse(
      "https://www.kitapyurdu.com/index.php?route=product/best_seller_products&list_id=16&category_id=128&filter_in_stock=1&sort=publish_date&order=DESC&limit=50");
  List<Book> books = [];

  bool isLoading = false;

  Future getData() async {
    setState(() {
      isLoading = true;
    });
    var res = await http.get(url);
    final body = res.body;
    final document = parser.parse(body);
    var response = document
        .getElementsByClassName("product-grid")[0]
        .getElementsByClassName("product-cr")
        .forEach((element) {
      setState(() {
        books.add(
          Book(
              image: element.children[2].children[0].children[0].children[0]
                  .attributes['src']
                  .toString(),
              bookName: element.children[3].text.toString(),
              publisher: element.children[4].text.toString(),
              author: element.children[5].text.toString(),
              price: element.children[8].children[0].text.toString()),
        );
      });
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Web Scraping KitapYurdu')),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: GridView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10),
                itemCount: books.length,
                itemBuilder: (context, index) => Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 7,
                  color: Colors.white10,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                books[index].image,
                                width: MediaQuery.of(context).size.width * 0.5,
                                height: MediaQuery.of(context).size.width * 0.5,
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Text(
                                index.toString(),
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Book Name: ${books[index].bookName}",
                          style: _style,
                        ),
                        Text(
                          "Book Publisher: ${books[index].publisher}",
                          style: _style,
                        ),
                        Text(
                          "Book Author: ${books[index].author}",
                          style: _style,
                        ),
                        Text(
                          "Book Price: ${books[index].price} ₺",
                          style: _style,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  final TextStyle _style = const TextStyle(color: Colors.white, fontSize: 15);
}
