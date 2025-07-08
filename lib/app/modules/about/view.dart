import 'package:flutter/material.dart';
import 'package:legalcm/app/utils/tools.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "About Page 🧾",
          style: Tools.H2(context).copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Developer Card
            Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      "Developed By:",
                      style: Tools.H2(context).copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "KAVIN M",
                      style: Tools.H2(context).copyWith(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Contact Info
            _buildInfoTile("📞 Phone", "+91 9384242333", context),
            _buildInfoTile("📧 Email", "mkavin2005@gmail.com", context),
            _buildInfoTile("📸 Instagram", "i_kavinm", context),
            _buildClickableTile(
              "💼 LinkedIn",
              "Kavin M",
              "https://www.linkedin.com/in/kavin-m--/",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, BuildContext context) {
    return ListTile(
      leading: Icon(Icons.info_outline, color: Colors.blueAccent),
      title: Text(
        label,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        value,
        style: Tools.H3(context).copyWith(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Widget _buildClickableTile(String label, String value, String url) {
    return ListTile(
      leading: Icon(Icons.link, color: Colors.blueAccent),
      title: Text(
        label,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: InkWell(
        onTap: () async {
          final Uri uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          } else {
            // print("Could not launch $url");
          }
        },
        child: Text(
          value,
          style: TextStyle(color: Colors.blue, fontSize: 18),
        ),
      ),
    );
  }
}
