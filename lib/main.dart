import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const navy = Color(0xFF09233F);
const gold = Color(0xFFC99A45);
const cream = Color(0xFFF7F4EE);
const muted = Color(0xFF667484);

class BookItem {
  final String id, category, title, question, answer;
  final List<String> keywords;
  BookItem.fromJson(Map<String, dynamic> j)
    : id = j['id'] as String,
      category = j['category'] as String,
      title = j['title'] as String,
      question = j['question'] as String,
      answer = j['answer'] as String,
      keywords = List<String>.from(j['keywords'] ?? const []);
}

class Topic {
  final String code, name, description;
  final IconData icon;
  const Topic(this.code, this.name, this.description, this.icon);
}

const topics = [
  Topic(
    'TKRS',
    'Tata Kelola Rumah Sakit',
    'Struktur organisasi, kepemimpinan, tata kelola, dan tanggung jawab unit.',
    Icons.account_balance_outlined,
  ),
  Topic(
    'KPS',
    'Kualifikasi & Pendidikan Staf',
    'Kompetensi, kredensial, dan orientasi staf.',
    Icons.groups_outlined,
  ),
  Topic(
    'MFK',
    'Manajemen Fasilitas & Keselamatan',
    'Kebakaran, evakuasi, bencana, dan fasilitas.',
    Icons.fire_extinguisher_outlined,
  ),
  Topic(
    'PPI',
    'Pencegahan & Pengendalian Infeksi',
    'Hand hygiene, APD, limbah, dan sterilisasi.',
    Icons.clean_hands_outlined,
  ),
  Topic(
    'PMKP',
    'Peningkatan Mutu & Keselamatan Pasien',
    'Indikator mutu, insiden, dan perbaikan.',
    Icons.trending_up_rounded,
  ),
  Topic(
    'MRMIK',
    'Manajemen Rekam Medis & Informasi Kesehatan',
    'Rekam medis, informasi kesehatan, dan keamanan data.',
    Icons.folder_shared_outlined,
  ),
  Topic(
    'AKP',
    'Akses & Kesinambungan Pelayanan',
    'Skrining, rujukan, transportasi, dan pemulangan.',
    Icons.route_outlined,
  ),
  Topic(
    'HPK',
    'Hak Pasien & Keluarga',
    'Privasi, persetujuan, hak, dan kewajiban pasien.',
    Icons.volunteer_activism_outlined,
  ),
  Topic(
    'PP',
    'Pengkajian Pasien',
    'Pengkajian awal, lanjutan, dan kebutuhan pasien.',
    Icons.assignment_ind_outlined,
  ),
  Topic(
    'PAP',
    'Pelayanan & Asuhan Pasien',
    'Pelayanan terintegrasi dan asuhan pasien.',
    Icons.medical_services_outlined,
  ),
  Topic(
    'PAB',
    'Pelayanan Anestesi & Bedah',
    'Anestesi, pembedahan, dan keselamatan tindakan.',
    Icons.local_hospital_outlined,
  ),
  Topic(
    'PKPO',
    'Pelayanan Kefarmasian & Obat',
    'High-alert, LASA, resep, dan obat emergensi.',
    Icons.medication_outlined,
  ),
  Topic(
    'KE & PKRS',
    'Komunikasi, Edukasi & PKRS',
    'Komunikasi, edukasi pasien, dan promosi kesehatan rumah sakit.',
    Icons.campaign_outlined,
  ),
  Topic(
    'SKP',
    'Sasaran Keselamatan Pasien',
    'Identifikasi, komunikasi, obat, infeksi, dan pasien jatuh.',
    Icons.health_and_safety_outlined,
  ),
  Topic(
    'Program Nasional',
    'Program Nasional',
    'Program prioritas nasional dan pelayanan terkait.',
    Icons.flag_outlined,
  ),
];

void main() => runApp(const BukuSakuApp());

class BukuSakuApp extends StatelessWidget {
  const BukuSakuApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Buku Saku RSGM AU',
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: cream,
      colorScheme: ColorScheme.fromSeed(seedColor: navy),
      fontFamily: 'Arial',
    ),
    home: const SplashPage(),
  );
}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: cream,
    body: Center(
      child: Semantics(
        button: true,
        label: 'Masuk ke Buku Saku RSGM AU',
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeShell()),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Image.asset(
              'assets/rsgmau_logo_gold_gemstone.png',
              width: 190,
              height: 190,
            ),
          ),
        ),
      ),
    ),
  );
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int selected = 0;
  List<BookItem> items = [];
  Set<String> completed = {};

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    final raw = await rootBundle.loadString('assets/rsgmau_content.json');
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      items = (jsonDecode(raw) as List)
          .map((e) => BookItem.fromJson(e))
          .toList();
      completed = (prefs.getStringList('rsgmau_completed') ?? []).toSet();
    });
  }

  void openTab(int index) => setState(() => selected = index);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(items: items, completed: completed, onTab: openTab),
      MateriPage(items: items, completed: completed),
      const PanduanPage(),
      const RsgmauPage(),
    ];
    return Scaffold(
      body: SafeArea(child: pages[selected]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: openTab,
        backgroundColor: Colors.white,
        indicatorColor: gold.withValues(alpha: .18),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          const NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Materi',
          ),
          const NavigationDestination(
            icon: Icon(Icons.bolt_outlined),
            selectedIcon: Icon(Icons.bolt),
            label: 'Panduan',
          ),
          NavigationDestination(
            icon: Image.asset(
              'assets/rsgmau_logo_gold_gemstone.png',
              width: 25,
              height: 25,
            ),
            selectedIcon: Image.asset(
              'assets/rsgmau_logo_gold_gemstone.png',
              width: 29,
              height: 29,
            ),
            label: 'RSGMAU',
          ),
        ],
      ),
    );
  }
}

class WelcomeMessage {
  final String title;
  final String body;
  final IconData icon;

  const WelcomeMessage(this.title, this.body, this.icon);
}

class RsgmauPage extends StatelessWidget {
  const RsgmauPage({super.key});

  static const messages = [
    WelcomeMessage(
      'Kepala Lakesgilut AU',
      '''Assalamu'alaikum warahmatullahi wabarakatuh.

Puji syukur ke hadirat Allah SWT atas hadirnya Aplikasi Buku Saku Akreditasi RSGM AU. Saya menyambut baik inovasi ini sebagai langkah nyata RSGM AU dalam memperkuat tata kelola, meningkatkan pemahaman staf, dan menumbuhkan budaya mutu secara berkelanjutan.

Akreditasi bukan tujuan akhir, melainkan sarana untuk memastikan pelayanan berjalan sesuai standar, aman, konsisten, dan berorientasi pada kebutuhan pasien. Karena itu, Buku Saku Akreditasi hendaknya digunakan sebagai rujukan bersama dalam pelaksanaan tugas sehari-hari, bukan hanya saat menghadapi survei akreditasi.

Saya menyampaikan apresiasi kepada Kepala RSGM AU, Ketua dan seluruh Tim Akreditasi, para Pokja, Tim Pengembang Aplikasi, serta seluruh staf atas kerja keras dan kolaborasinya. Semoga aplikasi ini terus dikembangkan, diperbarui, dan dimanfaatkan secara efektif oleh setiap unit pelayanan.

Semoga Buku Saku Akreditasi ini memperkuat komitmen RSGM AU dalam memberikan pelayanan kesehatan gigi dan mulut yang profesional, modern, bermutu, serta mengutamakan keselamatan pasien.

Mutu bukan hanya dinilai saat akreditasi; mutu tercermin dalam pelayanan setiap hari.

Wassalamu'alaikum warahmatullahi wabarakatuh.

Kepala Lakesgilut AU drg. R. Poerwanto
Marsekal Pertama TNI drg. Hedis Hendaya, Sp.BM.''',
      Icons.waving_hand_rounded,
    ),
    WelcomeMessage(
      'Kepala RSGMAU',
      '''Assalamualaikum Wr. Wb.

Puji syukur kita panjatkan kehadirat Allah SWT karena berkat rahmat dan hidayah-Nya Buku Saku Personel RSGMAU dapat kami susun sesuai dengan yang diharapkan.

Secara garis besar, buku ini berisi tentang visi, misi, 6 sasaran keselamatan pasien, pelaporan Insiden Keselamatan Pasien (IKP), peran dan tanggung jawab personel, hak pasien dan keluarga, customer service, panduan menghadapi kebakaran, serta simbol bahan dan daerah bahaya.

Buku Saku ini diharapkan dapat bermanfaat untuk mengenalkan dan mensosialisasikan secara ringkas program-program Mutu Pelayanan dan Keselamatan Pasien Rumah Sakit yang telah dan harus dilaksanakan oleh seluruh personel RSGMAU, terutama yang berhubungan langsung dengan pelayanan pada pasien dan keluarganya.

Dengan menerapkan isi buku saku ini, setiap personel RSGMAU dapat bekerja sama mewujudkan Rumah Sakit yang bermutu dan aman (safe hospital), melalui pembentukan budaya keselamatan (safe culture), keselamatan pelayanan (safe care), staf yang bertanggung jawab (safe staff), keterlibatan pasien (safe patient), sistem pendukung yang aman (safe support system), serta tempat yang aman (safe place).

Kami ucapkan terima kasih dan penghargaan yang setinggi-tingginya kepada semua pihak yang terlibat dalam penyusunan buku saku ini. Semoga buku saku ini dapat bermanfaat bagi personel RSGMAU dan dapat dipergunakan sebagaimana mestinya.

Wassalamualaikum Wr. Wb.

Kolonel Kes (W) drg. Annita Yunistuti, Sp.KG''',
      Icons.record_voice_over_rounded,
    ),
    WelcomeMessage(
      'Ketua Akreditasi RSGMAU',
      '''Assalamu'alaikum warahmatullahi wabarakatuh.

Puji syukur ke hadirat Allah SWT atas hadirnya Aplikasi Buku Saku Akreditasi RSGM AU. Buku saku ini disusun untuk menghadirkan informasi akreditasi secara ringkas, mudah dipahami, dan mudah diakses oleh seluruh staf RSGM AU.

Akreditasi bukan sekadar pemenuhan dokumen atau persiapan menghadapi survei. Akreditasi adalah budaya kerja yang harus tercermin dalam setiap pelayanan melalui kepatuhan terhadap standar, komunikasi yang baik, serta komitmen terhadap mutu dan keselamatan pasien.

Saya berharap Buku Saku Akreditasi ini dapat menjadi panduan praktis, menyatukan pemahaman seluruh staf, dan membantu setiap unit menerapkan standar secara konsisten. Isinya hendaknya terus dilengkapi dan diperbarui agar tetap relevan serta memberi manfaat nyata bagi pelayanan.

Terima kasih kepada Kepala RSGM AU, seluruh Pokja Akreditasi, Tim Pengembang Aplikasi, dan semua pihak yang telah berkontribusi. Semoga ikhtiar ini memperkuat budaya mutu dan mendukung terwujudnya pelayanan RSGM AU yang unggul, aman, dan berorientasi pada keselamatan pasien.

Satu genggaman, satu pemahaman, satu langkah menuju mutu.

Wassalamu'alaikum warahmatullahi wabarakatuh.

Ketua Akreditasi RSGM AU
drg. Muhammad Syafri, Sp.KG.''',
      Icons.message_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) => CustomScrollView(
    slivers: [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 4),
          child: Row(
            children: [
              Image.asset(
                'assets/rsgmau_logo_gold_gemstone.png',
                width: 48,
                height: 48,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'RSGMAU',
                  style: TextStyle(
                    color: navy,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 18),
          child: Text(
            'Sambutan dan pesan penting RSGMAU.',
            style: TextStyle(color: muted, height: 1.45),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, index) => _welcomeCard(messages[index]),
            childCount: messages.length,
          ),
        ),
      ),
    ],
  );

  static Widget _welcomeCard(WelcomeMessage message) => Card(
    elevation: 0,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
    child: ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      leading: CircleAvatar(
        backgroundColor: navy,
        child: Icon(message.icon, color: gold),
      ),
      title: Text(
        message.title,
        style: const TextStyle(color: navy, fontWeight: FontWeight.w800),
      ),
      subtitle: const Padding(
        padding: EdgeInsets.only(top: 5),
        child: Text('Buka sambutan', style: TextStyle(color: muted)),
      ),
      iconColor: navy,
      collapsedIconColor: navy,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            message.body,
            style: const TextStyle(color: navy, fontSize: 15, height: 1.6),
          ),
        ),
      ],
    ),
  );
}

class HomePage extends StatelessWidget {
  final List<BookItem> items;
  final Set<String> completed;
  final ValueChanged<int> onTab;
  const HomePage({
    super.key,
    required this.items,
    required this.completed,
    required this.onTab,
  });

  @override
  Widget build(BuildContext context) => CustomScrollView(
    slivers: [
      SliverToBoxAdapter(child: _header()),
      SliverToBoxAdapter(child: _hero(context)),
      SliverToBoxAdapter(child: _quickFeatures(context)),
      SliverToBoxAdapter(
        child: _sectionTitle('Topik Materi', 'Lihat semua', () => onTab(1)),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
        sliver: SliverGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.18,
          children: topics.take(6).map((t) => _topicCard(context, t)).toList(),
        ),
      ),
    ],
  );

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
    child: Row(
      children: [
        Image.asset(
          'assets/rsgmau_logo_gold_gemstone.png',
          width: 42,
          height: 42,
        ),
        const SizedBox(width: 11),
        const Expanded(
          child: Text(
            'Buku Saku RSGMAU',
            style: TextStyle(
              color: navy,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded, color: navy),
        ),
      ],
    ),
  );

  Widget _hero(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(18, 6, 18, 18),
    padding: const EdgeInsets.all(21),
    decoration: BoxDecoration(
      color: navy,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Siap menghadapi survei?',
          style: TextStyle(
            color: gold,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pelajari tugas, prosedur, dan jawaban penting akreditasi.',
          style: TextStyle(color: Colors.white, height: 1.45, fontSize: 14),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () => onTab(3),
          icon: const Icon(Icons.arrow_forward_rounded),
          label: const Text('Mulai latihan'),
          style: FilledButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: navy,
          ),
        ),
      ],
    ),
  );

  Widget _quickFeatures(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18),
    child: GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 11,
      crossAxisSpacing: 11,
      childAspectRatio: 1.7,
      children: [
        _feature('Materi Akreditasi', Icons.menu_book_rounded, () => onTab(1)),
        _feature('Panduan Cepat', Icons.bolt_rounded, () => onTab(2)),
        _feature(
          'Latihan Tanya Jawab',
          Icons.question_answer_rounded,
          () => onTab(3),
        ),
        _feature('Cari Materi', Icons.search_rounded, () => onTab(1)),
      ],
    ),
  );

  Widget _feature(String label, IconData icon, VoidCallback onTap) => Card(
    elevation: 0,
    color: Colors.white,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: navy.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: navy, size: 21),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: navy,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _sectionTitle(String title, String action, VoidCallback onTap) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: navy,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: onTap,
              child: Text(
                action,
                style: const TextStyle(
                  color: gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _topicCard(BuildContext context, Topic topic) => Card(
    elevation: 0,
    color: Colors.white,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
    child: InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              TopicPage(topic: topic, items: items, completed: completed),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(topic.icon, color: gold, size: 26),
            const Spacer(),
            Text(
              topic.code,
              style: const TextStyle(
                color: navy,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              topic.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: muted, fontSize: 11.5, height: 1.2),
            ),
          ],
        ),
      ),
    ),
  );
}

class MateriPage extends StatefulWidget {
  final List<BookItem> items;
  final Set<String> completed;
  const MateriPage({super.key, required this.items, required this.completed});
  @override
  State<MateriPage> createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final filtered = widget.items
        .where(
          (x) => '${x.title} ${x.question} ${x.answer} ${x.keywords.join(' ')}'
              .toLowerCase()
              .contains(query.toLowerCase()),
        )
        .toList();
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 22, 20, 5),
            child: Text(
              'Materi Akreditasi',
              style: TextStyle(
                color: navy,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: TextField(
              onChanged: (v) => setState(() => query = v),
              decoration: InputDecoration(
                hintText: 'Cari materi, istilah, atau prosedur',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              'Topik Pokja',
              style: const TextStyle(
                color: navy,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _topicRow(context, topics[i]),
              childCount: topics.length,
            ),
          ),
        ),
        if (query.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                'Hasil pencarian (${filtered.length})',
                style: const TextStyle(
                  color: navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        if (query.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _itemCard(context, filtered[i]),
              childCount: filtered.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }

  Widget _topicRow(BuildContext context, Topic t) => Card(
    elevation: 0,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: navy,
        child: Icon(t.icon, color: gold),
      ),
      title: Text(
        t.code,
        style: const TextStyle(color: navy, fontWeight: FontWeight.w900),
      ),
      subtitle: Text(
        t.name,
        style: const TextStyle(color: muted, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: navy),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TopicPage(
            topic: t,
            items: widget.items,
            completed: widget.completed,
          ),
        ),
      ),
    ),
  );
  Widget _itemCard(BuildContext context, BookItem item) => ListTile(
    title: Text(item.title),
    subtitle: Text(item.question, maxLines: 1, overflow: TextOverflow.ellipsis),
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailPage(item: item)),
    ),
  );
}

List<String> _importantPoints(String text) {
  final lines = text
      .split(RegExp(r'\r?\n+'))
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
  if (lines.length > 1) return lines;
  return text
      .split(';')
      .map((point) => point.trim())
      .where((point) => point.isNotEmpty)
      .toList();
}

class TopicPage extends StatelessWidget {
  final Topic topic;
  final List<BookItem> items;
  final Set<String> completed;
  const TopicPage({
    super.key,
    required this.topic,
    required this.items,
    required this.completed,
  });
  @override
  Widget build(BuildContext context) {
    final matches = items
        .where(
          (x) =>
              x.category.toLowerCase() == topic.code.toLowerCase() ||
              x.category.toLowerCase().contains(topic.code.toLowerCase()),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(topic.code),
        backgroundColor: navy,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            topic.name,
            style: const TextStyle(
              color: navy,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            topic.description,
            style: const TextStyle(color: muted, height: 1.4),
          ),
          const SizedBox(height: 22),
          if (topic.code == 'TKRS') _organisasiCard(context),
          if (topic.code == 'MFK') _aparCard(context),
          if (topic.code == 'KPS') _kpsVisualCard(),
          if (topic.code == 'HPK') _hpkPosterCard(),
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'Poin penting',
              style: TextStyle(
                color: navy,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          ...matches.map((item) => _importantPointCard(item)),
          if (matches.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text('Materi pokja ini sedang disiapkan.'),
            ),
        ],
      ),
    );
  }

  Widget _hpkPosterCard() => Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 18),
    color: Colors.white,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          'assets/kanal_pengaduan_hpk.jpg',
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(14, 13, 14, 14),
          child: Text(
            'Kanal saran dan pengaduan pasien — offline maupun online.',
            style: TextStyle(color: navy, height: 1.4, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );

  Widget _importantPointCard(BookItem item) {
    if (item.category == 'KPS') return _kpsStructuredCard(item);
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      color: navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (completed.contains(item.id))
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            ..._importantPoints(item.answer).map((point) => _plainPoint(point)),
          ],
        ),
      ),
    );
  }

  Widget _kpsStructuredCard(BookItem item) {
    final colors = [
      const Color(0xFF168AAD),
      const Color(0xFFF28F3B),
      const Color(0xFF7B61A8),
      const Color(0xFFE85D75),
      const Color(0xFFE0A11A),
    ];
    final points = _importantPoints(item.answer);
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: const TextStyle(
                color: navy,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 11),
            if (item.title == 'Staf Nonklinis: SIAP KERJA') _siapKerjaTable(),
            if (item.title != 'Staf Nonklinis: SIAP KERJA')
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Table(
                  columnWidths: const {
                    0: FixedColumnWidth(38),
                    1: FlexColumnWidth(1.05),
                    2: FlexColumnWidth(1.75),
                  },
                  border: TableBorder.all(
                    color: const Color(0xFFDCE4EA),
                    width: .8,
                  ),
                  children: points.asMap().entries.map((entry) {
                    final i = entry.key;
                    final point = entry.value;
                    final separator = point.indexOf(' — ');
                    final colon = point.indexOf(': ');
                    final splitAt = separator > 0 ? separator : colon;
                    final hasLabel = splitAt > 0;
                    final marker = hasLabel
                        ? (RegExp(r'^\\d+').firstMatch(point)?.group(0) ??
                              '${i + 1}')
                        : '•';
                    final label = hasLabel
                        ? point
                              .substring(0, splitAt)
                              .replaceFirst(RegExp(r'^\\d+\\.\\s*'), '')
                              .trim()
                        : '';
                    final body = hasLabel
                        ? point
                              .substring(splitAt + (separator > 0 ? 3 : 2))
                              .trim()
                        : point;
                    final accent = colors[i % colors.length];
                    return TableRow(
                      children: [
                        Container(
                          color: accent,
                          constraints: const BoxConstraints(minHeight: 56),
                          alignment: Alignment.center,
                          child: Text(
                            marker,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Container(
                          color: accent.withValues(alpha: .14),
                          constraints: const BoxConstraints(minHeight: 56),
                          padding: const EdgeInsets.all(8),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            label.isEmpty ? 'Poin penting' : label,
                            style: TextStyle(
                              color: accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                            ),
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          constraints: const BoxConstraints(minHeight: 56),
                          padding: const EdgeInsets.all(8),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            body,
                            style: const TextStyle(
                              color: Color(0xFF263532),
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _plainPoint(String point) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '•  ',
          style: TextStyle(
            color: gold,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        Expanded(
          child: Text(
            point,
            softWrap: true,
            style: const TextStyle(color: navy, height: 1.4),
          ),
        ),
      ],
    ),
  );

  Widget _kpsVisualCard() => Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    clipBehavior: Clip.antiAlias,
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: .82, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 14),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [navy, Color(0xFF164A73)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.psychology_alt_rounded, color: gold, size: 28),
                SizedBox(width: 9),
                Text(
                  'PETA HAFALAN KPS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '5 TEPAT',
              style: TextStyle(
                color: gold,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              'Orang • Kompetensi • Tugas • Penugasan • Terus dijaga',
              style: TextStyle(
                color: Colors.white,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 13),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children:
                  ['ORANG', 'KOMPETENSI', 'TUGAS', 'PENUGASAN', 'TERUS DIJAGA']
                      .map(
                        (label) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .14),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: gold.withValues(alpha: .65),
                            ),
                          ),
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 12),
            const Text(
              'Klinis: SIAP KLINIS  •  Nonklinis: SIAP KERJA  •  Semua staf: 5 JAGA',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _siapKerjaTable() {
    const rows = [
      (
        'S',
        'Seleksi & dokumen',
        'Kualifikasi, pendidikan, pengalaman, identitas, dan persyaratan jabatan diperiksa.',
      ),
      (
        'I',
        'Induksi/orientasi',
        'Mengikuti orientasi umum RSGM AU dan orientasi khusus unit.',
      ),
      (
        'A',
        'Asesmen awal',
        'Kepala unit menilai kompetensi/kinerja sebelum staf mulai bekerja.',
      ),
      (
        'P',
        'Penempatan & tugas',
        'Menerima penugasan, unit kerja, atasan langsung, dan uraian tugas yang jelas.',
      ),
      (
        'K',
        'Kerjakan sesuai SPO',
        'Bekerja sesuai uraian tugas, prosedur, target, serta batas tanggung jawab.',
      ),
      (
        'E',
        'Evaluasi kinerja',
        'Kinerja didokumentasikan minimal setiap tahun atau sesuai ketentuan RSGM AU.',
      ),
      (
        'R',
        'Rawat kompetensi',
        'Mengikuti pendidikan/pelatihan sesuai kebutuhan, risiko, dan hasil evaluasi.',
      ),
      (
        'J',
        'Jaga keselamatan',
        'Patuhi K3, PPI, BHD, keamanan data, etika, dan alur pelaporan insiden.',
      ),
      (
        'A',
        'Arsip diperbarui',
        'Laporkan perubahan data pendidikan, orientasi, tugas, pelatihan, kinerja, dan kesehatan.',
      ),
    ];
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(42),
          1: FlexColumnWidth(1.05),
          2: FlexColumnWidth(1.7),
        },
        border: TableBorder.all(color: const Color(0xFFD5E1DC), width: .8),
        children: rows
            .map(
              (row) => TableRow(
                children: [
                  Container(
                    constraints: const BoxConstraints(minHeight: 62),
                    color: const Color(0xFF12605D),
                    alignment: Alignment.center,
                    child: Text(
                      row.$1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(minHeight: 62),
                    color: const Color(0xFFE5F3EE),
                    padding: const EdgeInsets.all(9),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      row.$2,
                      style: const TextStyle(
                        color: Color(0xFF14534F),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(minHeight: 62),
                    color: Colors.white,
                    padding: const EdgeInsets.all(9),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      row.$3,
                      style: const TextStyle(
                        color: Color(0xFF263532),
                        fontSize: 11.5,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _organisasiCard(BuildContext context) => Card(
    elevation: 0,
    color: const Color(0xFFE7EEF5),
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      contentPadding: const EdgeInsets.all(14),
      leading: const CircleAvatar(
        backgroundColor: navy,
        child: Icon(Icons.account_tree_rounded, color: gold),
      ),
      title: const Text(
        'Struktur Organisasi RSGMAU',
        style: TextStyle(color: navy, fontWeight: FontWeight.w900),
      ),
      subtitle: const Text(
        'Bagan organisasi lengkap dan hubungan antarunit',
        style: TextStyle(color: navy, height: 1.35),
      ),
      trailing: const Icon(Icons.image_rounded, color: navy),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OrganisasiPage()),
      ),
    ),
  );

  Widget _aparCard(BuildContext context) => Card(
    elevation: 0,
    color: const Color(0xFFFFE7D6),
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      contentPadding: const EdgeInsets.all(14),
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFB53A1C),
        child: Icon(Icons.local_fire_department_rounded, color: Colors.white),
      ),
      title: const Text(
        'Sosialisasi APAR',
        style: TextStyle(color: Color(0xFF7A2412), fontWeight: FontWeight.w900),
      ),
      subtitle: const Text(
        'Paparan lengkap: proteksi kebakaran dan penggunaan APAR\n24 slide',
        style: TextStyle(color: Color(0xFF7A2412), height: 1.35),
      ),
      trailing: const Icon(Icons.slideshow_rounded, color: Color(0xFFB53A1C)),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AparPage()),
      ),
    ),
  );
}

class AparPage extends StatelessWidget {
  const AparPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Sosialisasi APAR'),
      backgroundColor: const Color(0xFF7A2412),
      foregroundColor: Colors.white,
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 28),
      children: [
        const Text(
          'Pelatihan Proteksi Kebakaran dan Penggunaan APAR',
          style: TextStyle(
            color: navy,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Paparan lengkap dari file SOSIALISASI APAR.pptx. Geser ke bawah untuk melihat seluruh slide.',
          style: TextStyle(color: muted, height: 1.4),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          24,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/apar/slide-${(i + 1).toString().padLeft(2, '0')}.jpg',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class OrganisasiPage extends StatelessWidget {
  const OrganisasiPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Struktur Organisasi'),
      backgroundColor: navy,
      foregroundColor: Colors.white,
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 28),
      children: [
        const Text(
          'STRUKTUR ORGANISASI RSGMAU',
          style: TextStyle(
            color: navy,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Bagan organisasi ditampilkan sebagai materi visual TKRS.',
          style: TextStyle(color: muted, height: 1.4),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 4,
            child: Image.asset(
              'assets/struktur_organisasi_rsgmau.jpg',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Perbesar gambar untuk membaca unit dan keterangan yang berukuran kecil.',
          style: TextStyle(color: muted, fontSize: 12),
        ),
      ],
    ),
  );
}

class PengaduanPage extends StatelessWidget {
  const PengaduanPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Alur Pengaduan Pasien'),
      backgroundColor: navy,
      foregroundColor: Colors.white,
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 28),
      children: [
        const Text(
          'ALUR PENGADUAN LANGSUNG & TIDAK LANGSUNG',
          style: TextStyle(
            color: navy,
            fontSize: 21,
            height: 1.2,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Alur penanganan pengaduan pasien RSGMAU.',
          style: TextStyle(color: muted, height: 1.4),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 4,
            child: Image.asset(
              'assets/alur_pengaduan_pasien.jpg',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Perbesar gambar untuk membaca alur, kategori pengaduan, tindak lanjut, dan informasi kontak.',
          style: TextStyle(color: muted, fontSize: 12),
        ),
      ],
    ),
  );
}

class RacePassPage extends StatelessWidget {
  const RacePassPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Kebakaran — RACE & PASS'),
      backgroundColor: const Color(0xFF7A2412),
      foregroundColor: Colors.white,
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.asset(
            'assets/race_pass_illustration.png',
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Panduan Cepat Kebakaran',
          style: TextStyle(
            color: navy,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Lakukan tindakan sesuai kondisi, utamakan keselamatan pasien dan diri sendiri, serta ikuti SPO kebakaran RSGMAU.',
          style: TextStyle(color: muted, height: 1.45),
        ),
        const SizedBox(height: 18),
        _block(
          'RACE — TINDAKAN AWAL',
          const Color(0xFF0E5B78),
          Icons.emergency_rounded,
          [
            'R — Rescue/Remove: selamatkan atau pindahkan pasien dan orang yang berada dalam bahaya.',
            'A — Alarm/Alert: aktifkan alarm, bunyikan kode darurat, dan laporkan kepada petugas/piket.',
            'C — Confine/Contain: tutup pintu dan batasi penyebaran asap atau api bila aman.',
            'E — Extinguish/Evacuate: gunakan APAR bila api kecil dan aman; bila tidak, segera evakuasi.',
          ],
        ),
        _block(
          'PASS — CARA MENGGUNAKAN APAR',
          const Color(0xFFB53A1C),
          Icons.fire_extinguisher_rounded,
          [
            'P — Pull: tarik pin pengaman APAR.',
            'A — Aim: arahkan nozzle ke pangkal api.',
            'S — Squeeze: tekan tuas APAR secara terkontrol.',
            'S — Sweep: sapukan semprotan dari sisi ke sisi pada pangkal api.',
          ],
        ),
        _block(
          'APAR BOLEH DIGUNAKAN JIKA',
          const Color(0xFF315C45),
          Icons.check_circle_outline_rounded,
          [
            'Api masih kecil dan terbatas.',
            'Jalur keluar masih terbuka.',
            'Petugas mengetahui cara menggunakan APAR.',
            'Jenis APAR sesuai kelas kebakaran.',
            'Penggunaan tidak membahayakan pasien maupun petugas.',
          ],
        ),
        _block(
          'SEGERA EVAKUASI JIKA',
          const Color(0xFF8A5A20),
          Icons.exit_to_app_rounded,
          [
            'Api membesar atau menyebar cepat.',
            'Asap terlalu tebal atau jalur keluar tertutup.',
            'Tidak mengetahui sumber api atau APAR tidak sesuai.',
            'Keselamatan pasien dan petugas mulai terancam.',
          ],
        ),
        _block(
          'JANGAN DILAKUKAN',
          const Color(0xFF7A2412),
          Icons.warning_amber_rounded,
          [
            'Jangan melawan api yang sudah besar atau masuk ke ruangan penuh asap.',
            'Jangan menggunakan air pada kebakaran listrik.',
            'Jangan menghalangi jalur evakuasi dan jangan kembali mengambil barang.',
            'Jangan menggunakan lift saat kebakaran.',
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Catatan: panduan ini adalah materi edukasi. Untuk pelaksanaan resmi, ikuti SPO kebakaran, evakuasi, kode darurat, dan instruksi petugas berwenang RSGMAU.',
          style: TextStyle(color: muted, fontSize: 12, height: 1.45),
        ),
      ],
    ),
  );

  Widget _block(
    String title,
    Color color,
    IconData icon,
    List<String> points,
  ) => Card(
    elevation: 0,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: points
                .map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '•  ',
                          style: TextStyle(
                            color: gold,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            p,
                            style: const TextStyle(
                              color: navy,
                              height: 1.4,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    ),
  );
}

class CodeBluePage extends StatefulWidget {
  const CodeBluePage({super.key});
  @override
  State<CodeBluePage> createState() => _CodeBluePageState();
}

class _CodeBluePageState extends State<CodeBluePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController pulse;
  @override
  void initState() {
    super.initState();
    pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Code Blue'),
      backgroundColor: const Color(0xFF0B477D),
      foregroundColor: Colors.white,
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      children: [
        AnimatedBuilder(
          animation: pulse,
          builder: (_, child) =>
              Transform.scale(scale: 1 + pulse.value * .025, child: child),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1261A0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.monitor_heart_rounded,
                  color: Colors.white,
                  size: 42,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CODE BLUE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Respons cepat pada kegawatan medis dan henti jantung',
                        style: TextStyle(color: Colors.white70, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _block(
          'KENALI & AKTIFKAN',
          const Color(0xFF0E5B78),
          Icons.visibility_rounded,
          [
            'Pastikan lokasi aman.',
            'Periksa respons dan napas pasien secara singkat.',
            'Jika pasien tidak responsif dan tidak bernapas normal, segera aktifkan Code Blue sesuai sistem RSGMAU dan minta bantuan.',
          ],
        ),
        _block(
          'LAKUKAN BANTUAN AWAL',
          const Color(0xFFB53A1C),
          Icons.favorite_rounded,
          [
            'Mulai CPR segera bila terlatih dan aman dilakukan.',
            'Minta AED/defibrilator dan perlengkapan resusitasi dibawa ke lokasi.',
            'Lakukan kompresi dada berkualitas dan ikuti instruksi AED/defibrilator oleh petugas terlatih.',
          ],
        ),
        _block('TIM CODE BLUE', const Color(0xFF315C45), Icons.groups_rounded, [
          'Tim pertama mengamankan lokasi, memulai bantuan hidup dasar, dan menyampaikan informasi pasien.',
          'Pemimpin tim mengatur pembagian tugas, komunikasi, evaluasi respons, dan eskalasi bantuan.',
          'Anggota tim melaksanakan tindakan sesuai kompetensi, kewenangan, dan SPO yang berlaku.',
        ]),
        _block(
          'SETELAH KEGAWATAN',
          const Color(0xFF8A5A20),
          Icons.fact_check_rounded,
          [
            'Pastikan pasien mendapat perawatan lanjutan atau serah terima yang jelas.',
            'Dokumentasikan waktu aktivasi, respons, tindakan, alat, dan hasil sesuai ketentuan.',
            'Lakukan debriefing dan pelaporan insiden/perbaikan mutu sesuai kebijakan rumah sakit.',
          ],
        ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1D6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            'PENTING: Code Blue adalah sistem rumah sakit. Ikuti nomor aktivasi, lokasi tim, pembagian peran, algoritme resusitasi, dan SPO Code Blue RSGMAU yang berlaku. Jangan memberikan obat atau tindakan lanjutan di luar kompetensi dan kewenangan.',
            style: TextStyle(
              color: navy,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Rujukan penyusunan',
          style: TextStyle(color: navy, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        const Text(
          '• Kementerian Kesehatan RI — Mengenal Istilah Code Blue.\n• American Heart Association — 2025 Guidelines for CPR and ECC.\n• Resuscitation Council UK — 2025 Adult Basic Life Support dan Advanced Life Support Guidelines.',
          style: TextStyle(color: muted, fontSize: 12, height: 1.5),
        ),
      ],
    ),
  );

  Widget _block(
    String title,
    Color color,
    IconData icon,
    List<String> points,
  ) => Card(
    elevation: 0,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 11, 15, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: points
                .map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '•  ',
                          style: TextStyle(
                            color: gold,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            p,
                            style: const TextStyle(
                              color: navy,
                              height: 1.4,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    ),
  );
}

class BhdPage extends StatelessWidget {
  const BhdPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Bantuan Hidup Dasar'),
      backgroundColor: const Color(0xFF126257),
      foregroundColor: Colors.white,
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.asset('assets/bhd_hero.png', fit: BoxFit.cover),
        ),
        const SizedBox(height: 16),
        const Text(
          'BANTUAN HIDUP DASAR',
          style: TextStyle(
            color: navy,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Respons awal yang cepat, aman, dan terkoordinasi pada pasien yang mengalami kegawatan.',
          style: TextStyle(color: muted, height: 1.45),
        ),
        const SizedBox(height: 18),
        _safety(
          '3A — PASTIKAN KESELAMATAN',
          const Color(0xFF0E5B78),
          Icons.shield_rounded,
          [
            'Aman penolong: gunakan APD sesuai risiko dan jangan menolong bila lokasi membahayakan.',
            'Aman pasien: pastikan identitas, kondisi, posisi, dan kebutuhan bantuan pasien.',
            'Aman lingkungan: amankan sumber bahaya, beri ruang untuk tim, dan minta orang sekitar membantu akses.',
          ],
        ),
        _safety(
          'KENALI & PANGGIL BANTUAN',
          const Color(0xFFB53A1C),
          Icons.campaign_rounded,
          [
            'Periksa respons pasien dan napas secara singkat.',
            'Jika tidak responsif dan tidak bernapas normal, segera aktifkan Code Blue sesuai sistem RSGMAU.',
            'Minta seseorang mengambil AED/defibrilator dan perlengkapan resusitasi.',
          ],
        ),
        _safety(
          'CPR BERKUALITAS',
          const Color(0xFF1261A0),
          Icons.favorite_rounded,
          [
            'Mulai kompresi dada segera bila terlatih dan aman dilakukan.',
            'Biarkan dada mengembang kembali dan minimalkan jeda kompresi.',
            'Lakukan ventilasi sesuai pelatihan, APD, alat yang tersedia, dan kebijakan rumah sakit.',
          ],
        ),
        _safety(
          'AED & TIM RESUSITASI',
          const Color(0xFF8A5A20),
          Icons.monitor_heart_rounded,
          [
            'Pasang dan gunakan AED/defibrilator segera setelah tersedia oleh petugas yang kompeten.',
            'Ikuti instruksi alat; pastikan tidak ada orang menyentuh pasien saat analisis atau kejut.',
            'Serahkan penanganan lanjutan kepada tim resusitasi dan ikuti arahan pemimpin tim.',
          ],
        ),
        _safety(
          'SETELAH TINDAKAN',
          const Color(0xFF315C45),
          Icons.fact_check_rounded,
          [
            'Lakukan serah terima dan perawatan lanjutan sesuai keputusan tim.',
            'Dokumentasikan waktu, tindakan, alat, respons, dan hasil sesuai ketentuan.',
            'Lakukan debriefing dan pelaporan sesuai kebijakan rumah sakit.',
          ],
        ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1D6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            'PENTING: Materi ini bersifat edukasi. Nomor aktivasi Code Blue, pembagian peran, algoritme, obat, kejut, ventilasi, dan tindakan lanjutan wajib mengikuti SPO RSGMAU serta kompetensi dan kewenangan petugas.',
            style: TextStyle(
              color: navy,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Rujukan penyusunan',
          style: TextStyle(color: navy, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        const Text(
          '• American Heart Association — 2025 Guidelines for CPR and ECC.\n• Resuscitation Council UK — 2025 Adult Basic Life Support Guidelines.\n• Kementerian Kesehatan RI — materi Code Blue dan sistem kegawatan rumah sakit.',
          style: TextStyle(color: muted, fontSize: 12, height: 1.5),
        ),
      ],
    ),
  );

  Widget _safety(
    String title,
    Color color,
    IconData icon,
    List<String> points,
  ) => Card(
    elevation: 0,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 11, 15, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: points
                .map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '•  ',
                          style: TextStyle(
                            color: gold,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            p,
                            style: const TextStyle(
                              color: navy,
                              height: 1.4,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    ),
  );
}

class EvakuasiPage extends StatelessWidget {
  const EvakuasiPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Evakuasi & Titik Kumpul'),
      backgroundColor: const Color(0xFF2C6339),
      foregroundColor: Colors.white,
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.asset('assets/evakuasi_hero.png', fit: BoxFit.cover),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/titik_kumpul_rsgmau.jpg',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TITIK KUMPUL',
                      style: TextStyle(
                        color: const Color(0xFF2C6339),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Kenali rambu hijau bertuliskan “TITIK KUMPUL / ASSEMBLY POINT” di area yang telah ditentukan.',
                      style: TextStyle(color: muted, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'DOKUMENTASI LAPANGAN',
          style: TextStyle(
            color: navy,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Kenali rambu titik kumpul dan lingkungan sekitarnya dari beberapa sudut pandang.',
          style: TextStyle(color: muted, height: 1.4),
        ),
        const SizedBox(height: 10),
        ...[
          'assets/titik_kumpul_rsgmau_02.jpg',
          'assets/titik_kumpul_rsgmau_03.jpg',
          'assets/titik_kumpul_rsgmau_04.jpg',
          'assets/titik_kumpul_rsgmau_05.jpg',
        ].asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                entry.value,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'EVAKUASI RUMAH SAKIT',
          style: TextStyle(
            color: navy,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Pindahkan pasien dan pengunjung secara tertib menuju area aman sesuai arahan petugas.',
          style: TextStyle(color: muted, height: 1.45),
        ),
        const SizedBox(height: 18),
        _block(
          'SAAT EVAKUASI',
          const Color(0xFF2C6339),
          Icons.directions_run_rounded,
          [
            'Tetap tenang dan ikuti instruksi petugas atau pemimpin evakuasi.',
            'Dahulukan pasien yang paling rentan dan membutuhkan bantuan.',
            'Gunakan jalur evakuasi yang ditetapkan; jangan gunakan lift saat keadaan darurat kebakaran.',
            'Jangan kembali mengambil barang dan jangan menghalangi akses tim tanggap darurat.',
          ],
        ),
        _block(
          'MENUJU TITIK KUMPUL',
          const Color(0xFF0E5B78),
          Icons.location_on_rounded,
          [
            'Berjalan tertib menuju titik kumpul yang telah ditentukan RSGMAU.',
            'Bantu pasien, keluarga, dan pengunjung yang membutuhkan pendampingan.',
            'Lakukan pendataan atau pengecekan keberadaan sesuai instruksi koordinator.',
            'Jangan meninggalkan titik kumpul sebelum dinyatakan aman.',
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'PETA LOKASI',
          style: TextStyle(
            color: navy,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InteractiveViewer(
            minScale: .8,
            maxScale: 4,
            child: Image.asset(
              'assets/peta_evakuasi_rsgmau.jpg',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Gunakan peta sebagai informasi lokasi. Jalur dan titik kumpul operasional harus mengikuti denah resmi serta instruksi petugas RSGMAU di lokasi.',
          style: TextStyle(color: muted, fontSize: 12, height: 1.45),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1D6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            'PENTING: Materi ini bersifat edukasi. Ikuti SPO evakuasi, kode darurat, jalur resmi, titik kumpul resmi, dan arahan petugas berwenang RSGMAU.',
            style: TextStyle(
              color: navy,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _block(
    String title,
    Color color,
    IconData icon,
    List<String> points,
  ) => Card(
    elevation: 0,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 11, 15, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: points
                .map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '•  ',
                          style: TextStyle(
                            color: gold,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            p,
                            style: const TextStyle(
                              color: navy,
                              height: 1.4,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    ),
  );
}

class PasienJatuhPage extends StatelessWidget {
  const PasienJatuhPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Pasien Jatuh'),
      backgroundColor: const Color(0xFF855A13),
      foregroundColor: Colors.white,
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      children: [
        const Text(
          'PENANGANAN PASIEN JATUH',
          style: TextStyle(
            color: navy,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Panduan edukasi alur respons umum di rumah sakit. Utamakan keselamatan, jangan langsung mengangkat pasien, dan ikuti SPO RSGMAU.',
          style: TextStyle(color: muted, height: 1.45),
        ),
        const SizedBox(height: 16),
        _step(
          '1  AMANKAN & TENANGKAN',
          'assets/jatuh_01_aman.png',
          const Color(0xFF0E5B78),
          [
            'Amankan area dan minta bantuan petugas.',
            'Tenangkan pasien; jangan memindahkan atau mengangkat sebelum dinilai.',
            'Jangan meninggalkan pasien sendirian.',
          ],
        ),
        _step(
          '2  ASSESSMENT SEGERA',
          'assets/jatuh_02_assessment.png',
          const Color(0xFFB53A1C),
          [
            'Periksa respons, napas, nyeri, perdarahan, deformitas, benturan kepala, dan keluhan lain.',
            'Periksa tanda vital dan lakukan pemeriksaan sesuai kompetensi.',
            'Jika kondisi gawat, aktifkan respons emergensi/Code Blue sesuai sistem RSGMAU.',
          ],
        ),
        _step(
          '3  BANTU SETELAH AMAN',
          'assets/jatuh_03_bantu.png',
          const Color(0xFF315C45),
          [
            'Jangan memaksa pasien berdiri.',
            'Setelah dinilai aman oleh petugas berwenang, bantu perubahan posisi dengan teknik dan alat yang sesuai.',
            'Lakukan rujukan atau pemeriksaan lanjutan bila ada indikasi klinis.',
          ],
        ),
        _step(
          '4  DOKUMENTASI & CEGAH ULANG',
          'assets/jatuh_04_dokumentasi.png',
          const Color(0xFF8A5A20),
          [
            'Catat waktu, lokasi, saksi, kondisi pasien, hasil assessment, tindakan, dan respons.',
            'Informasikan dokter/penanggung jawab dan keluarga sesuai kebijakan.',
            'Tinjau faktor risiko, lingkungan, alas kaki, bel pemanggil, posisi tempat tidur, serta rencana pencegahan berikutnya.',
          ],
        ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1D6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            'CATATAN SPO: Alur ini adalah panduan edukasi berbasis praktik keselamatan pasien. Nomor pelaporan, formulir, kriteria eskalasi, pembagian peran, dan tata cara mobilisasi wajib mengikuti SPO Pasien Jatuh RSGMAU yang berlaku.',
            style: TextStyle(
              color: navy,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Rujukan penyusunan',
          style: TextStyle(color: navy, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        const Text(
          '• AHRQ — Preventing Falls in Hospitals Toolkit.\n• AHRQ PSNet — Falls and post-fall review.\n• Joint Commission — individualized fall-prevention interventions.',
          style: TextStyle(color: muted, fontSize: 12, height: 1.5),
        ),
      ],
    ),
  );

  Widget _step(String title, String image, Color color, List<String> points) =>
      Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: const Color(0xFFF4F8FA),
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.asset(image, fit: BoxFit.contain),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              color: color,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 11, 15, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: points
                    .map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '•  ',
                              style: TextStyle(
                                color: gold,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                p,
                                style: const TextStyle(
                                  color: navy,
                                  height: 1.4,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      );
}

class PanduanPage extends StatelessWidget {
  const PanduanPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
      children: [
        const Text(
          'Panduan Cepat',
          style: TextStyle(
            color: navy,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Akses cepat untuk prosedur penting di lingkungan rumah sakit.',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 20),

        Card(
          elevation: 0,
          color: const Color(0xFFE8F0F6),
          margin: const EdgeInsets.only(bottom: 11),
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: const CircleAvatar(
              backgroundColor: navy,
              child: Icon(Icons.support_agent_rounded, color: gold),
            ),
            title: const Text(
              'Alur Pengaduan Pasien',
              style: TextStyle(color: navy, fontWeight: FontWeight.w900),
            ),
            subtitle: const Text(
              'Alur pengaduan langsung dan tidak langsung RSGMAU',
              style: TextStyle(color: muted, height: 1.35),
            ),
            trailing: const Icon(Icons.image_rounded, color: navy),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PengaduanPage()),
            ),
          ),
        ),
        Card(
          elevation: 0,
          color: const Color(0xFFFFE8D9),
          margin: const EdgeInsets.only(bottom: 11),
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFB53A1C),
              child: Icon(
                Icons.local_fire_department_rounded,
                color: Colors.white,
              ),
            ),
            title: const Text(
              'Kebakaran — RACE & PASS',
              style: TextStyle(
                color: Color(0xFF7A2412),
                fontWeight: FontWeight.w900,
              ),
            ),
            subtitle: const Text(
              'Panduan tindakan awal dan penggunaan APAR',
              style: TextStyle(color: Color(0xFF7A2412), height: 1.35),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFB53A1C),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RacePassPage()),
            ),
          ),
        ),
        Card(
          elevation: 0,
          color: const Color(0xFFE6F0FF),
          margin: const EdgeInsets.only(bottom: 11),
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF1261A0),
              child: Icon(Icons.monitor_heart_rounded, color: Colors.white),
            ),
            title: const Text(
              'Code Blue',
              style: TextStyle(
                color: Color(0xFF0B477D),
                fontWeight: FontWeight.w900,
              ),
            ),
            subtitle: const Text(
              'Respons cepat pada kegawatan medis dan henti jantung',
              style: TextStyle(color: Color(0xFF0B477D), height: 1.35),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF1261A0),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CodeBluePage()),
            ),
          ),
        ),
        Card(
          elevation: 0,
          color: const Color(0xFFE8F6F2),
          margin: const EdgeInsets.only(bottom: 11),
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF147D70),
              child: Icon(Icons.favorite_rounded, color: Colors.white),
            ),
            title: const Text(
              'Bantuan Hidup Dasar',
              style: TextStyle(
                color: Color(0xFF126257),
                fontWeight: FontWeight.w900,
              ),
            ),
            subtitle: const Text(
              '3A, CPR, AED, dan respons awal kegawatan',
              style: TextStyle(color: Color(0xFF126257), height: 1.35),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF147D70),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BhdPage()),
            ),
          ),
        ),
        Card(
          elevation: 0,
          color: const Color(0xFFE9F4EA),
          margin: const EdgeInsets.only(bottom: 11),
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF3C7A4A),
              child: Icon(Icons.exit_to_app_rounded, color: Colors.white),
            ),
            title: const Text(
              'Evakuasi & Titik Kumpul',
              style: TextStyle(
                color: Color(0xFF2C6339),
                fontWeight: FontWeight.w900,
              ),
            ),
            subtitle: const Text(
              'Jalur evakuasi, peta lokasi, dan titik kumpul RSGMAU',
              style: TextStyle(color: Color(0xFF2C6339), height: 1.35),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF3C7A4A),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EvakuasiPage()),
            ),
          ),
        ),
        Card(
          elevation: 0,
          color: const Color(0xFFFFF2DE),
          margin: const EdgeInsets.only(bottom: 11),
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFB87818),
              child: Icon(Icons.accessibility_new_rounded, color: Colors.white),
            ),
            title: const Text(
              'Pasien Jatuh',
              style: TextStyle(
                color: Color(0xFF855A13),
                fontWeight: FontWeight.w900,
              ),
            ),
            subtitle: const Text(
              'Alur respons, assessment, bantuan, dan pencegahan',
              style: TextStyle(color: Color(0xFF855A13), height: 1.35),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFB87818),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PasienJatuhPage()),
            ),
          ),
        ),
      ],
    );
  }
}

class TimPokjaPage extends StatelessWidget {
  const TimPokjaPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Daftar Nama'),
      backgroundColor: navy,
      foregroundColor: Colors.white,
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
      children: [
        const Text(
          'Daftar Nama RSGMAU',
          style: TextStyle(
            color: navy,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Pilih bagian daftar nama yang ingin dibaca.',
          style: TextStyle(color: muted, height: 1.4),
        ),
        const SizedBox(height: 20),
        _menu(
          context,
          'Daftar Nama Pengawakan RSGMAU',
          'Pimpinan dan pengawakan unit RSGMAU',
          Icons.account_tree_rounded,
          const Color(0xFF0E5B78),
          'DAFTAR NAMA PENGAWAKAN RSGMAU',
          null,
        ),
        _menu(
          context,
          'Daftar Nama Tim Pokja Reakreditasi Starkes 2026',
          'Seluruh tim, pelaksana, dan asesor internal',
          Icons.groups_rounded,
          const Color(0xFF7A2412),
          'DAFTAR NAMA TIM POKJA REAKREDITASI STARKES 2026',
          null,
        ),
        _menu(
          context,
          'Kelompok Manajemen Rumah Sakit',
          'TKRS, KPS, MFK, PMKP, MRMIK, dan PPI',
          Icons.business_rounded,
          const Color(0xFF315C45),
          'KELOMPOK MANAJEMEN RUMAH SAKIT',
          'KELOMPOK PELAYANAN BERFOKUS PADA PASIEN',
        ),
        _menu(
          context,
          'Kelompok Pelayanan Berfokus pada Pasien',
          'AKP, HPK, PP, PAP, PAB, PKPO, dan KE & PKRS',
          Icons.medical_services_rounded,
          const Color(0xFF8A5A20),
          'KELOMPOK PELAYANAN BERFOKUS PADA PASIEN',
          'KELOMPOK SASARAN KESELAMATAN PASIEN',
        ),
      ],
    ),
  );

  Widget _menu(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String start,
    String? end,
  ) => Card(
    elevation: 0,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      contentPadding: const EdgeInsets.all(15),
      leading: CircleAvatar(
        backgroundColor: color,
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(
        title,
        style: const TextStyle(color: navy, fontWeight: FontWeight.w900),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: const TextStyle(color: muted, height: 1.35),
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: navy),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RosterTextPage(title: title, start: start, end: end),
        ),
      ),
    ),
  );
}

class RosterTextPage extends StatelessWidget {
  final String title, start;
  final String? end;
  const RosterTextPage({
    super.key,
    required this.title,
    required this.start,
    required this.end,
  });
  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
    future: DefaultAssetBundle.of(context).loadString('assets/roster_text.txt'),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final all = snapshot.data!
          .split('\n')
          .where((x) => x.trim().isNotEmpty)
          .toList();
      final from = all.indexWhere((x) => x.trim() == start);
      final to = end == null
          ? all.length
          : all.indexWhere((x) => x.trim() == end);
      final lines = all.sublist(from < 0 ? 0 : from, to < 0 ? all.length : to);
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: navy,
          foregroundColor: Colors.white,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 30),
          children: [
            Text(
              title,
              style: const TextStyle(
                color: navy,
                fontSize: 23,
                height: 1.15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Nama dan jabatan ditulis sebagai teks dari roster buku sumber.',
              style: TextStyle(color: muted, height: 1.4),
            ),
            const SizedBox(height: 18),
            ...lines.map((line) {
              final clean = line.trim();
              final heading =
                  clean.startsWith('DAFTAR NAMA') ||
                  clean.startsWith('KELOMPOK ') ||
                  RegExp(
                    r'^(I|II|III|IV|V|VI|VII|VIII|IX|X|XI|XII|XIII|XIV|XV|XVII)\\.',
                  ).hasMatch(clean);
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: EdgeInsets.symmetric(
                  horizontal: heading ? 14 : 12,
                  vertical: heading ? 12 : 9,
                ),
                decoration: BoxDecoration(
                  color: heading
                      ? (clean.contains('PENGAWAKAN')
                            ? const Color(0xFF0E5B78)
                            : const Color(0xFF7A2412))
                      : Colors.white,
                  borderRadius: BorderRadius.circular(heading ? 12 : 9),
                  border: heading
                      ? null
                      : Border.all(color: navy.withValues(alpha: .08)),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final parts = clean
                        .split(RegExp(r'\\s{2,}'))
                        .where((x) => x.trim().isNotEmpty)
                        .toList();
                    final style = TextStyle(
                      color: heading ? Colors.white : navy,
                      fontFamily: heading ? null : 'monospace',
                      fontSize: heading ? 14 : 12,
                      height: 1.45,
                      fontWeight: heading ? FontWeight.w900 : FontWeight.w500,
                    );
                    if (heading || parts.length < 2) {
                      return Text(clean, softWrap: true, style: style);
                    }
                    if (constraints.maxWidth < 560) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: parts
                            .map(
                              (part) => Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  part.trim(),
                                  softWrap: true,
                                  style: style,
                                ),
                              ),
                            )
                            .toList(),
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: parts
                          .map(
                            (part) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Text(
                                  part.trim(),
                                  softWrap: true,
                                  style: style,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      );
    },
  );
}

class LatihanPage extends StatelessWidget {
  final List<BookItem> items;
  const LatihanPage({super.key, required this.items});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
    children: [
      const Text(
        'Latihan',
        style: TextStyle(
          color: navy,
          fontSize: 25,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'Uji kesiapan menghadapi pertanyaan asesor.',
        style: TextStyle(color: muted),
      ),
      const SizedBox(height: 20),
      _mode(
        context,
        'Latihan Tanya Jawab',
        'Pertanyaan acak dari buku saku.',
        Icons.question_answer_rounded,
        () => _start(context),
      ),
      _mode(
        context,
        'Kuis Materi',
        'Periksa pemahaman setiap pokja.',
        Icons.quiz_rounded,
        () => _start(context),
      ),
      _mode(
        context,
        'Simulasi Survei',
        'Latihan menjawab seperti saat survei.',
        Icons.record_voice_over_rounded,
        () => _start(context),
      ),
    ],
  );
  Widget _mode(
    BuildContext context,
    String title,
    String desc,
    IconData icon,
    VoidCallback onTap,
  ) => Card(
    elevation: 0,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      contentPadding: const EdgeInsets.all(14),
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: navy,
        child: Icon(icon, color: gold),
      ),
      title: Text(
        title,
        style: const TextStyle(color: navy, fontWeight: FontWeight.w800),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(desc),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 17),
      onTap: onTap,
    ),
  );
  void _start(BuildContext context) {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Materi sedang dimuat.')));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailPage(item: items.first)),
    );
  }
}

class DetailPage extends StatefulWidget {
  final BookItem item;
  const DetailPage({super.key, required this.item});
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool completed = false;
  @override
  void initState() {
    super.initState();
    _read();
  }

  Future<void> _read() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) {
      setState(
        () => completed = (p.getStringList('rsgmau_completed') ?? []).contains(
          widget.item.id,
        ),
      );
    }
  }

  Future<void> _complete() async {
    final p = await SharedPreferences.getInstance();
    final x = (p.getStringList('rsgmau_completed') ?? []).toSet()
      ..add(widget.item.id);
    await p.setStringList('rsgmau_completed', x.toList());
    if (mounted) setState(() => completed = true);
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.item.category == 'PPI'
        ? widget.item.answer
              .split('\n')
              .map((x) => x.trim())
              .where((x) => x.isNotEmpty)
              .toList()
        : widget.item.answer
              .split(RegExp(r';|\.'))
              .map((x) => x.trim())
              .where((x) => x.isNotEmpty)
              .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.category),
        backgroundColor: navy,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: gold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.item.category,
                  style: const TextStyle(
                    color: navy,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'PAPARAN MATERI',
                style: TextStyle(
                  color: muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            widget.item.title,
            style: const TextStyle(
              color: navy,
              fontSize: 27,
              height: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          if (widget.item.category != 'PPI')
            _presentationBlock(
              label: 'PERTANYAAN SURVEI',
              icon: Icons.help_outline_rounded,
              color: navy,
              textColor: Colors.white,
              child: Text(
                widget.item.question,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(height: 14),
          if (widget.item.category != 'PPI')
            _presentationBlock(
              label: 'JAWABAN INTI',
              icon: Icons.lightbulb_outline_rounded,
              color: const Color(0xFFFFF1D6),
              textColor: navy,
              child: Text(
                widget.item.answer,
                style: const TextStyle(
                  color: navy,
                  fontSize: 16,
                  height: 1.65,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (widget.item.id == 'hpk-005') ...[
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD9E4EE)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/kanal_pengaduan_hpk.jpg',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(14, 13, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KANAL SARAN & PENGADUAN',
                          style: TextStyle(
                            color: navy,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: .4,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'Offline: kotak saran di Ruang Pendaftaran Pasien atau pengaduan langsung melalui Front Office Lakesgilutau/drg. R. Poerwanto.',
                          style: TextStyle(color: navy, height: 1.4, fontSize: 13),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Online: WhatsApp 0821-143-0506, Instagram @lakesgilutau dan @rsgm_angkatan_udara, serta rsgmtniau.com.',
                          style: TextStyle(color: muted, height: 1.4, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (points.length > 1) ...[
            const SizedBox(height: 18),
            const Text(
              'POIN PENTING',
              style: TextStyle(
                color: navy,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 9),
            ...points.asMap().entries.map(
              (entry) => Container(
                margin: const EdgeInsets.only(bottom: 9),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border(left: BorderSide(color: gold, width: 5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        color: gold,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          color: navy,
                          height: 1.4,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: navy.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: navy, size: 19),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Gunakan jawaban ini sebagai ringkasan belajar. Untuk pelaksanaan, ikuti SPO dan ketentuan resmi RSGMAU yang berlaku.',
                    style: TextStyle(color: muted, height: 1.4, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 17),
          const Text(
            'KATA KUNCI',
            style: TextStyle(
              color: navy,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: widget.item.keywords
                .map(
                  (x) => Chip(
                    label: Text(x),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: gold.withValues(alpha: .55)),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: completed ? null : _complete,
            icon: Icon(completed ? Icons.check_circle : Icons.done),
            label: Text(
              completed ? 'Sudah dipelajari' : 'Tandai sudah dipelajari',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: navy,
              foregroundColor: gold,
              padding: const EdgeInsets.all(15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _presentationBlock({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required Widget child,
  }) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: .8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        child,
      ],
    ),
  );
}
