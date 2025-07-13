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
          style: Tools.h2(context).copyWith(color: Colors.white),
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
                      style: Tools.h2(context).copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "KAVIN M",
                      style: Tools.h2(context).copyWith(
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
              "https://www.linkedin.com/in/kavin-m--",
              context,
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
        style: Tools.h3(context).copyWith(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Widget _buildClickableTile(String label, String value, String url, BuildContext context) {
    return ListTile(
      leading: Icon(Icons.link, color: Colors.blueAccent),
      title: Text(
        label,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: InkWell(
        onTap: () async {
          await _launchURL(url, context);
        },
        child: Text(
          value,
          style: TextStyle(
            color: Colors.blue,
            fontSize: 18,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url, BuildContext context) async {
    try {
      final Uri uri = Uri.parse(url);
      
      // First try to launch with external application mode
      if (await canLaunchUrl(uri)) {
        final bool launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        if (!launched) {
          // If external application fails, try in-app browser
          final bool launchedInApp = await launchUrl(
            uri,
            mode: LaunchMode.inAppWebView,
          );
          
          if (!launchedInApp) {
            _showErrorSnackBar(context, "Could not launch $url");
          }
        }
      } else {
        // If canLaunchUrl returns false, try alternative approach
        final bool launched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
        
        if (!launched) {
          _showErrorSnackBar(context, "No app found to open $url");
        }
      }
    } catch (e) {
      _showErrorSnackBar(context, "Error launching URL: $e");
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Copy URL',
          textColor: Colors.white,
          onPressed: () {
            // You can add clipboard functionality here if needed
          },
        ),
      ),
    );
  }
}
