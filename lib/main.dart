import 'package:flutter/material.dart';

void main() => runApp(const StreamCatchApp());

const _background = Color(0xFF080706);
const _panel = Color(0xFF151311);
const _panelRaised = Color(0xFF24211F);
const _orange = Color(0xFFFF6A00);
const _purple = Color(0xFF392116);
const _muted = Color(0xFF9A9692);

const _demoStills = <String>[
  'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?auto=format&fit=crop&w=600&q=85',
  'https://images.unsplash.com/photo-1485846234645-a62644f84728?auto=format&fit=crop&w=600&q=85',
  'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?auto=format&fit=crop&w=600&q=85',
  'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=600&q=85',
  'https://images.unsplash.com/photo-1478720568477-152d9b164e26?auto=format&fit=crop&w=600&q=85',
];

class StreamCatchApp extends StatelessWidget {
  const StreamCatchApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'StreamCatch',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _background,
      colorScheme: const ColorScheme.dark(
        primary: _orange,
        secondary: _purple,
        surface: _panel,
      ),
      useMaterial3: true,
      fontFamily: 'Roboto',
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _panel,
        hintStyle: const TextStyle(color: _muted, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide.none,
        ),
      ),
    ),
    home: _StreamCatchShell(),
  );
}

enum _Page {
  welcome,
  signIn,
  home,
  search,
  details,
  library,
  downloads,
  profile,
  communities,
  messages,
  conversation,
  watchTogether,
  watchRoom,
}

class _StreamCatchShell extends StatefulWidget {
  const _StreamCatchShell();

  @override
  State<_StreamCatchShell> createState() => _StreamCatchShellState();
}

class _StreamCatchShellState extends State<_StreamCatchShell> {
  _Page _page = _Page.home;
  _Page _previousPage = _Page.home;
  final _messageController = TextEditingController();
  final List<String> _conversationMessages = [
    'Not yet! Adding it to my list now.',
  ];
  int _libraryTab = 0;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final Set<String> _savedTitles = <String>{};
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  String? _linkMessage;

  @override
  void dispose() {
    _searchController.dispose();
    _linkController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _go(_Page page) => setState(() => _page = page);

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    setState(() {
      _conversationMessages.add(message);
      _messageController.clear();
    });
  }

  void _openDetails() {
    setState(() {
      _previousPage = _page;
      _page = _Page.details;
    });
  }

  void _toggleSaved(String title) {
    setState(() {
      if (!_savedTitles.add(title)) _savedTitles.remove(title);
    });
  }

  void _message(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(text), backgroundColor: _panelRaised),
    );

  void _checkLink() {
    final uri = Uri.tryParse(_linkController.text.trim());
    final valid =
        uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;
    setState(() {
      _linkMessage = valid
          ? 'The link format is valid. Source support and download permission checks are not connected yet.'
          : 'Enter a complete http or https video link.';
    });
  }

  Widget _buildPage() => switch (_page) {
    _Page.welcome => _WelcomePage(
      onExplore: () => _go(_Page.home),
      onSignIn: () => _go(_Page.signIn),
    ),
    _Page.signIn => _SignInPage(
      onBack: () => _go(_Page.welcome),
      onSignIn: () => _go(_Page.home),
      onCreateAccount: () =>
          _message('Account creation will connect to the StreamCatch API.'),
    ),
    _Page.home => _HomePage(
      onMovie: _openDetails,
      isSaved: _savedTitles.contains('28 Years Later'),
      selectedCategory: _selectedCategory,
      onCategoryChanged: (category) => setState(() => _selectedCategory = category),
      onWatchlist: () {
        _toggleSaved('28 Years Later');
        _message(
          _savedTitles.contains('28 Years Later')
              ? 'Added to My Library.'
              : 'Removed from My Library.',
        );
      },
      onSearch: () => _go(_Page.search),
      onDownloads: () => _go(_Page.downloads),
      onMessages: () => _go(_Page.messages),
    ),
    _Page.search => _SearchPage(
      controller: _searchController,
      query: _searchQuery,
      onQueryChanged: (value) => setState(() => _searchQuery = value),
      onMovie: _openDetails,
    ),
    _Page.details => _MovieDetailsPage(
      isSaved: _savedTitles.contains('28 Years Later'),
      onBack: () => _go(_previousPage),
      onWatchlist: () => _toggleSaved('28 Years Later'),
      onTrailer: () => _message(
        'Official trailer playback will be added with the authorized provider integration.',
      ),
    ),
    _Page.library => _LibraryPage(
      selectedTab: _libraryTab,
      onTabChanged: (index) => setState(() => _libraryTab = index),
      savedTitles: _savedTitles,
      onMovie: _openDetails,
    ),
    _Page.downloads => _DownloadsPage(
      controller: _linkController,
      message: _linkMessage,
      onCheck: _checkLink,
    ),
    _Page.profile => _ProfilePage(
      savedCount: _savedTitles.length,
      onDownloads: () => _go(_Page.downloads),
      onCommunities: () => _go(_Page.communities),
      onMessages: () => _go(_Page.messages),
      onWatchTogether: () => _go(_Page.watchTogether),
      onAccount: () => _message(
        'Profiles and account settings will connect to the StreamCatch API.',
      ),
    ),
    _Page.communities => _PhaseTwoPage(
      eyebrow: 'COMING SOON',
      title: 'Find your people.',
      body: 'Public and private movie communities, discussions, member lists, and moderation tools are planned here.',
      icon: Icons.forum_outlined,
    ),
    _Page.messages => _MessagesPage(
      onConversation: () => _go(_Page.conversation),
    ),
    _Page.conversation => _ConversationPage(
      controller: _messageController,
      messages: _conversationMessages,
      onSend: _sendMessage,
      onBack: () => _go(_Page.messages),
    ),
    _Page.watchTogether => _WatchTogetherPage(
      onRoom: () => _go(_Page.watchRoom),
    ),
    _Page.watchRoom => _PhaseTwoPage(
      eyebrow: 'COMING SOON',
      title: 'Movie night, together.',
      body: 'Playback synchronization, room chat, invitations, and supported authorized media will connect to WebSockets and WebRTC services.',
      icon: Icons.screen_share_outlined,
    ),
  };

  int get _selectedTab => switch (_page) {
    _Page.search => 1,
    _Page.messages || _Page.conversation => 2,
    _Page.library => 3,
    _Page.profile ||
    _Page.downloads ||
    _Page.communities ||
    _Page.watchTogether ||
    _Page.watchRoom => 4,
    _ => 0,
  };

  @override
  Widget build(BuildContext context) {
    final isMainPage = _page != _Page.welcome && _page != _Page.signIn;
    final showNavigation =
        isMainPage &&
        _page != _Page.details &&
        _page != _Page.conversation &&
        _page != _Page.watchRoom;
    final wide = MediaQuery.sizeOf(context).width > 720;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: wide ? 820 : 520),
            child: Column(
              children: [
                if (isMainPage && _page != _Page.home)
                  _AppHeader(onMessages: () => _go(_Page.messages)),
                Expanded(child: _buildPage()),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: showNavigation
          ? _BottomNavigation(
              selectedIndex: _selectedTab,
              onSelect: (index) => _go(switch (index) {
                0 => _Page.home,
                1 => _Page.search,
                2 => _Page.messages,
                3 => _Page.library,
                _ => _Page.profile,
              }),
            )
          : null,
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? _orange : _panel,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: selected ? Colors.white : Colors.white70, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
    ),
  );
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({this.size = 40});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: _orange, shape: BoxShape.circle, boxShadow: [BoxShadow(color: _orange.withOpacity(.4), blurRadius: 17)]),
    child: Icon(Icons.play_arrow_rounded, size: size * .62, color: Colors.white),
  );
}

class _ZombiePosterArt extends StatelessWidget {
  const _ZombiePosterArt();

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: RadialGradient(center: Alignment(.15, -.2), radius: 1.1, colors: [Color(0xFF3A0A08), Color(0xFF150706), Color(0xFF050505)]),
    ),
    child: Stack(fit: StackFit.expand, children: [
      Center(child: Icon(Icons.coronavirus_rounded, size: 188, color: const Color(0xFFE71922).withOpacity(.82))),
      const Positioned(left: 12, top: 14, child: Text('A NEW WORLD. A NEW FEAR.', style: TextStyle(fontSize: 6, letterSpacing: 1.2, color: Colors.white70, fontWeight: FontWeight.w700))),
    ]),
  );
}
class _AppHeader extends StatelessWidget {
  const _AppHeader({required this.onMessages});
  final VoidCallback onMessages;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 7, 16, 7),
    child: Row(
      children: [
        const _BrandMark(size: 27),
        const SizedBox(width: 8),
        const Text(
          'STREAMCATCH',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Messages',
          onPressed: onMessages,
          icon: const Icon(Icons.chat_bubble_outline, size: 20, color: _muted),
        ),
      ],
    ),
  );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({this.size = 90});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: _orange,
      borderRadius: BorderRadius.circular(size * .15),
    ),
    child: Icon(
      Icons.play_arrow_rounded,
      color: Colors.white,
      size: size * .68,
    ),
  );
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.onExplore, required this.onSignIn});
  final VoidCallback onExplore;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 22),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight - 58),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Eyebrow('WELCOME TO STREAMCATCH'),
            const SizedBox(height: 14),
            const Text(
              'STREAMCATCH',
              style: TextStyle(
                fontSize: 13,
                letterSpacing: 2.2,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 42),
            const _WelcomeCollage(),
            const SizedBox(height: 23),
            const Text(
              'Find your next favourite story.',
              style: TextStyle(
                fontSize: 29,
                height: 1.12,
                fontWeight: FontWeight.w700,
                letterSpacing: -.6,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Discover movies and series, save what you love, and find new stories to watch.',
              style: TextStyle(fontSize: 13, color: _muted, height: 1.45),
            ),
            const SizedBox(height: 28),
            _PrimaryButton(label: 'Explore movies', onPressed: onExplore),
            const SizedBox(height: 15),
            Center(
              child: TextButton(
                onPressed: onSignIn,
                child: const Text(
                  'Already have an account?  Sign in',
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _WelcomeCollage extends StatelessWidget {
  const _WelcomeCollage();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 255,
    child: Stack(
      alignment: Alignment.center,
      children: [
        _WelcomePoster(
          image: 0,
          left: 8,
          top: 29,
          angle: -.20,
          width: 112,
          height: 170,
        ),
        _WelcomePoster(
          image: 1,
          right: 8,
          top: 29,
          angle: .20,
          width: 112,
          height: 170,
        ),
        _WelcomePoster(
          image: 3,
          left: 32,
          bottom: 5,
          angle: -.13,
          width: 115,
          height: 173,
        ),
        _WelcomePoster(
          image: 4,
          right: 32,
          bottom: 5,
          angle: .13,
          width: 115,
          height: 173,
        ),
        _WelcomePoster(
          image: 2,
          angle: 0,
          width: 138,
          height: 210,
          featured: true,
        ),
        Positioned(
          bottom: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: _orange,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'YOUR NEXT MOVIE NIGHT STARTS HERE',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: .7,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _WelcomePoster extends StatelessWidget {
  const _WelcomePoster({
    required this.image,
    this.left,
    this.right,
    this.top,
    this.bottom,
    required this.angle,
    required this.width,
    required this.height,
    this.featured = false,
  });
  final int image;
  final double? left, right, top, bottom;
  final double angle, width, height;
  final bool featured;

  @override
  Widget build(BuildContext context) => Positioned(
    left: left,
    right: right,
    top: top,
    bottom: bottom,
    child: Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(featured ? 12 : 9),
          border: Border.all(
            color: Colors.white.withOpacity(featured ? .24 : .08),
            width: featured ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.5),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              _demoStills[image],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_purple, _orange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC000000)],
                ),
              ),
            ),
            if (featured)
              const Positioned(
                left: 9,
                bottom: 11,
                right: 8,
                child: Text(
                  'CINEMA\nBEGINS HERE',
                  style: TextStyle(
                    fontSize: 14,
                    height: .95,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .5,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _SignInPage extends StatelessWidget {
  const _SignInPage({
    required this.onBack,
    required this.onSignIn,
    required this.onCreateAccount,
  });
  final VoidCallback onBack;
  final VoidCallback onSignIn;
  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      const SizedBox(height: 18),
      const _Eyebrow('STREAMCATCH'),
      const SizedBox(height: 9),
      const Text(
        'Welcome back',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 5),
      const Text(
        'Your next great movie is waiting.',
        style: TextStyle(color: _muted, fontSize: 13),
      ),
      const SizedBox(height: 35),
      const _FieldLabel('EMAIL ADDRESS'),
      const SizedBox(height: 8),
      const TextField(
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(hintText: 'you@example.com'),
      ),
      const SizedBox(height: 21),
      const _FieldLabel('PASSWORD'),
      const SizedBox(height: 8),
      const TextField(
        obscureText: true,
        decoration: InputDecoration(hintText: 'Enter your password'),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {},
          child: const Text(
            'Forgot password?',
            style: TextStyle(color: _muted, fontSize: 11),
          ),
        ),
      ),
      _PrimaryButton(label: 'Sign in', onPressed: onSignIn),
      const SizedBox(height: 15),
      OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.g_mobiledata, size: 24),
        label: const Text('Continue with Google'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: _panel,
          minimumSize: const Size.fromHeight(46),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      const SizedBox(height: 18),
      Center(
        child: TextButton(
          onPressed: onCreateAccount,
          child: const Text(
            'New to StreamCatch?  Create an account',
            style: TextStyle(color: _muted, fontSize: 11),
          ),
        ),
      ),
    ],
  );
}

class _HomePage extends StatelessWidget {
  const _HomePage({
    required this.onMovie,
    required this.isSaved,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onWatchlist,
    required this.onSearch,
    required this.onDownloads,
    required this.onMessages,
  });
  final VoidCallback onMovie;
  final bool isSaved;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final VoidCallback onWatchlist;
  final VoidCallback onSearch;
  final VoidCallback onDownloads;
  final VoidCallback onMessages;

  @override
  Widget build(BuildContext context) {
    final allTitles = <_DemoTitle>[
      const _DemoTitle('28 YEARS LATER', 0, '8.7', 'Movies', _purple),
      const _DemoTitle('LIFE OF CHUCK', 1, '8.1', 'Movies', _panelRaised),
      const _DemoTitle('JURASSIC WORLD', 3, '7.8', 'Movies', _orange),
      const _DemoTitle('FRIENDS', 4, '8.9', 'Series', Color(0xFF332C24)),
      const _DemoTitle('THE FALL', 2, '7.9', 'Movies', Color(0xFF25201D)),
      const _DemoTitle('THE BEAR', 3, '8.6', 'TV show', Color(0xFF26302D)),
    ];
    final visibleTitles = selectedCategory == 'All'
        ? allTitles
        : allTitles.where((title) => title.category == selectedCategory).toList();

    return ListView(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
    children: [
      Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, Mohshihi!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.35,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Discover a story worth watching',
                  style: TextStyle(color: _muted, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onSearch,
            icon: const Icon(Icons.search_rounded, color: Colors.white70),
          ),
          IconButton(
            onPressed: onMessages,
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      const SizedBox(height: 7),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final category in ['All', 'Movies', 'Series', 'TV show'])
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _CategoryChip(
                  label: category,
                  selected: selectedCategory == category,
                  onTap: () => onCategoryChanged(category),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 15),
      _FeaturedMovie(
        isSaved: isSaved,
        onDetails: onMovie,
        onWatchlist: onWatchlist,
      ),
      const SizedBox(height: 24),
      _SectionHeader('Trending Now', onAction: onSearch),
      const SizedBox(height: 12),
      SizedBox(
        height: 174,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: visibleTitles
              .map(
                (title) => _MoviePoster(
                  title: title.title,
                  color: title.color,
                  image: title.image,
                  rating: title.rating,
                  onTap: onMovie,
                ),
              )
              .toList(),
        ),
      ),
      const SizedBox(height: 20),
      _SectionHeader('Picked for you', onAction: onSearch),
      const SizedBox(height: 12),
      SizedBox(
        height: 174,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _MoviePoster(
              title: 'QUIET EARTH',
              color: Color(0xFF252331),
              image: 2,
              rating: '4.4',
              onTap: onMovie,
            ),
            _MoviePoster(
              title: '28 YEARS LATER',
              color: _purple,
              image: 0,
              rating: '8.7',
              onTap: onMovie,
            ),
            _MoviePoster(
              title: 'LIFE OF CHUCK',
              color: _orange,
              image: 1,
              rating: '8.1',
              onTap: onMovie,
            ),
            _MoviePoster(
              title: 'FRIENDS',
              color: Color(0xFF26334B),
              image: 4,
              rating: '8.9',
              onTap: onMovie,
            ),
          ],
        ),
      ),
      const SizedBox(height: 22),
      Row(
        children: [
          Expanded(
            child: _QuickLink(
              icon: Icons.download_outlined,
              label: 'Downloads',
              onTap: onDownloads,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _QuickLink(
              icon: Icons.chat_bubble_outline,
              label: 'Messages',
              onTap: onMessages,
            ),
          ),
        ],
      ),
    ],
  );
  }
}

class _DemoTitle {
  const _DemoTitle(this.title, this.image, this.rating, this.category, this.color);
  final String title;
  final int image;
  final String rating;
  final String category;
  final Color color;
}

class _FeaturedMovie extends StatelessWidget {
  const _FeaturedMovie({
    required this.isSaved,
    required this.onDetails,
    required this.onWatchlist,
  });
  final bool isSaved;
  final VoidCallback onDetails;
  final VoidCallback onWatchlist;

  @override
  Widget build(BuildContext context) => Container(
    height: 245,
    decoration: BoxDecoration(
      color: _purple,
      borderRadius: BorderRadius.circular(15),
    ),
    clipBehavior: Clip.antiAlias,
    child: Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          _demoStills[2],
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8A3900), Color(0xFF3F1E0A), _panel],
              ),
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Color(0x22000000),
                Color(0xE6000000),
              ],
            ),
          ),
        ),
        const Center(child: _PlayButton(size: 48)),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton.filledTonal(
            tooltip: isSaved ? 'Remove from watchlist' : 'Add to watchlist',
            onPressed: onWatchlist,
            icon: Icon(isSaved ? Icons.favorite : Icons.favorite_border),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withOpacity(.38),
              foregroundColor: isSaved ? _orange : Colors.white,
            ),
          ),
        ),
        Positioned(
          left: 16,
          top: 15,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'STREAMCATCH ORIGINALS',
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 15,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '28 YEARS LATER',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .2,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Horror  ·  2025  ·  1h 55min',
                style: TextStyle(fontSize: 11, color: Colors.white70),
              ),
              const SizedBox(height: 11),
              SizedBox(
                width: double.infinity,
                child: _PrimaryButton(
                  label: 'View details',
                  onPressed: onDetails,
                  height: 39,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SearchPage extends StatelessWidget {
  const _SearchPage({
    required this.controller,
    required this.query,
    required this.onQueryChanged,
    required this.onMovie,
  });
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onMovie;

  @override
  Widget build(BuildContext context) {
    const genres = [
      'Action',
      'Drama',
      'Comedy',
      'Sci-Fi',
      'Thriller',
      'Romance',
      'Family',
    ];
    final catalog = [
      '28 Years Later',
      'The Life of Chuck',
      'Jurassic World',
      'The Family',
      'Friends',
    ];
    final results = query.isEmpty
        ? catalog
        : catalog
              .where((name) => name.toLowerCase().contains(query.toLowerCase()))
              .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        const _Eyebrow('EXPLORE THE CATALOGUE'),
        const SizedBox(height: 7),
        const Text(
          'Find a story',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: controller,
          onChanged: onQueryChanged,
          decoration: const InputDecoration(
            hintText: 'Search movies, shows, people…',
            prefixIcon: Icon(Icons.search, color: _muted),
          ),
        ),
        const SizedBox(height: 20),
        const _SectionHeader('Browse genres'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 7,
          runSpacing: 8,
          children: genres.map((genre) => _GenreChip(label: genre)).toList(),
        ),
        const SizedBox(height: 22),
        const _SectionHeader('Popular searches'),
        const SizedBox(height: 8),
        for (final term in [
          'Latest releases',
          'Award-winning films',
          'African cinema',
          'Family night picks',
        ])
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.trending_up, color: _muted, size: 18),
            title: Text(term, style: const TextStyle(fontSize: 12)),
            onTap: () {
              controller.text = term;
              onQueryChanged(term);
            },
          ),
        const SizedBox(height: 14),
        _SectionHeader(query.isEmpty ? 'Trending this week' : 'Search results'),
        const SizedBox(height: 11),
        if (results.isEmpty)
          const _EmptyState(
            icon: Icons.search_off,
            title: 'No titles found',
            body: 'Try another title, genre, or person.',
          )
        else
          ...results.map(
            (title) => _SearchResult(title: title, onTap: onMovie),
          ),
      ],
    );
  }
}

class _MovieDetailsPage extends StatelessWidget {
  const _MovieDetailsPage({
    required this.isSaved,
    required this.onBack,
    required this.onWatchlist,
    required this.onTrailer,
  });
  final bool isSaved;
  final VoidCallback onBack;
  final VoidCallback onWatchlist;
  final VoidCallback onTrailer;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 7, 20, 25),
    children: [
      Row(
        children: [
          IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
          const _Eyebrow('MOVIE DETAILS'),
        ],
      ),
      const SizedBox(height: 5),
      const Text(
        '28 YEARS LATER',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: .5,
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 225,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _ZombiePosterArt(),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x22000000), Color(0xCC000000)],
                ),
              ),
            ),
            const Center(child: _PlayButton(size: 53)),
            const Positioned(
              left: 14,
              bottom: 13,
              child: Text(
                '28 YEARS LATER',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.7,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      const Text(
        '2025  ·  Horror  ·  1h 55min  ·  18+',
        style: TextStyle(color: _muted, fontSize: 11),
      ),
      const SizedBox(height: 8),
      const Row(
        children: [
          Icon(Icons.star, color: _orange, size: 17),
          SizedBox(width: 5),
          Text(
            '8.7 / 10',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
      const SizedBox(height: 13),
      _PrimaryButton(label: 'Watch trailer', onPressed: onTrailer, height: 40),
      const SizedBox(height: 9),
      _SecondaryButton(
        label: isSaved ? '✓  Added to watchlist' : '+  Add to watchlist',
        onPressed: onWatchlist,
      ),
      const SizedBox(height: 21),
      const _SectionHeader('Synopsis'),
      const SizedBox(height: 7),
      const Text(
        'Decades after a virus devastates the world, survivors face a new and terrifying reality beyond the quarantine zone.',
        style: TextStyle(color: _muted, height: 1.5, fontSize: 12),
      ),
      const SizedBox(height: 20),
      const _SectionHeader('Cast & crew'),
      const SizedBox(height: 11),
      const Row(
        children: [
          Expanded(child: _CastPerson(name: 'Jodie Comer')),
          Expanded(child: _CastPerson(name: 'Ralph Fiennes')),
          Expanded(child: _CastPerson(name: 'Aaron Taylor-Johnson')),
        ],
      ),
      const SizedBox(height: 18),
      const Text(
        'Where to watch · verified providers only',
        style: TextStyle(color: _muted, fontSize: 10),
      ),
    ],
  );
}

class _LibraryPage extends StatelessWidget {
  const _LibraryPage({
    required this.selectedTab,
    required this.onTabChanged,
    required this.savedTitles,
    required this.onMovie,
  });
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  final Set<String> savedTitles;
  final VoidCallback onMovie;

  @override
  Widget build(BuildContext context) {
    final titles = selectedTab == 0 && savedTitles.isEmpty
        ? const <String>[]
        : selectedTab == 0
        ? savedTitles.toList()
        : selectedTab == 1
        ? ['28 Years Later', 'Jurassic World']
        : ['The Life of Chuck'];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      children: [
        const _Eyebrow('YOUR MOVIES'),
        const SizedBox(height: 6),
        const Text(
          'My Library',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _PillTab(
              label: 'Watchlist',
              selected: selectedTab == 0,
              onTap: () => onTabChanged(0),
            ),
            const SizedBox(width: 7),
            _PillTab(
              label: 'History',
              selected: selectedTab == 1,
              onTap: () => onTabChanged(1),
            ),
            const SizedBox(width: 7),
            _PillTab(
              label: 'My ratings',
              selected: selectedTab == 2,
              onTap: () => onTabChanged(2),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (titles.isEmpty)
          const _EmptyState(
            icon: Icons.bookmark_border,
            title: 'Your watchlist is waiting',
            body: 'Save a movie to find it here later.',
          )
        else
          ...titles.map((title) => _LibraryTitle(title: title, onTap: onMovie)),
      ],
    );
  }
}

class _DownloadsPage extends StatelessWidget {
  const _DownloadsPage({
    required this.controller,
    required this.message,
    required this.onCheck,
  });
  final TextEditingController controller;
  final String? message;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
    children: [
      const _Eyebrow('WATCH OFFLINE'),
      const SizedBox(height: 6),
      const Text(
        'Downloads',
        style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 13),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _FieldLabel('LINK SCANNER'),
            const SizedBox(height: 8),
            const Text(
              'Check a video link',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              'Paste a direct file or streaming link you are authorized to download.',
              style: TextStyle(color: _muted, fontSize: 11, height: 1.4),
            ),
            const SizedBox(height: 11),
            TextField(
              controller: controller,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'Paste a direct video URL…',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 9),
            _PrimaryButton(label: 'Check link', onPressed: onCheck, height: 38),
            if (message != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  message!,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 19),
      const _SectionHeader('Active downloads', actionText: '0'),
      const SizedBox(height: 9),
      const _DownloadPlaceholder(
        title: 'No active downloads',
        subtitle: 'Authorized downloads will appear here.',
      ),
      const SizedBox(height: 15),
      const _SectionHeader('Completed', actionText: '0'),
      const SizedBox(height: 9),
      const _DownloadPlaceholder(
        title: 'Nothing saved yet',
        subtitle: 'Your completed offline titles will be listed here.',
      ),
      const SizedBox(height: 16),
      const Text(
        'Supported: direct MP4 links and unencrypted HLS playlists, where authorized. StreamCatch will not bypass DRM, encryption, or access controls. Some webpages cannot be downloaded.',
        style: TextStyle(color: _muted, fontSize: 10, height: 1.45),
      ),
    ],
  );
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({
    required this.savedCount,
    required this.onDownloads,
    required this.onCommunities,
    required this.onMessages,
    required this.onWatchTogether,
    required this.onAccount,
  });
  final int savedCount;
  final VoidCallback onDownloads;
  final VoidCallback onCommunities;
  final VoidCallback onMessages;
  final VoidCallback onWatchTogether;
  final VoidCallback onAccount;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
    children: [
      const _Eyebrow('YOUR STREAMCATCH'),
      const SizedBox(height: 6),
      const Text(
        'Your profile',
        style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 16),
      const Center(
        child: CircleAvatar(
          radius: 34,
          backgroundColor: _purple,
          child: Text(
            'KC',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
      ),
      const SizedBox(height: 9),
      const Center(
        child: Text(
          'Kachi N.',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      const SizedBox(height: 2),
      const Center(
        child: Text(
          '@kachi.movies',
          style: TextStyle(color: _muted, fontSize: 11),
        ),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            Expanded(
              child: _StatCell(value: '$savedCount', label: 'Saved'),
            ),
            const Expanded(
              child: _StatCell(value: '08', label: 'Reviews'),
            ),
            const Expanded(
              child: _StatCell(value: '24', label: 'Watched'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 17),
      _SettingsRow(
        icon: Icons.person_outline,
        label: 'Account details',
        onTap: onAccount,
      ),
      _SettingsRow(
        icon: Icons.download_outlined,
        label: 'Downloads & offline',
        onTap: onDownloads,
      ),
      _SettingsRow(
        icon: Icons.forum_outlined,
        label: 'Communities',
        onTap: onCommunities,
        phaseTwo: true,
      ),
      _SettingsRow(
        icon: Icons.chat_bubble_outline,
        label: 'Messages',
        onTap: onMessages,
        phaseTwo: true,
      ),
      _SettingsRow(
        icon: Icons.groups_outlined,
        label: 'Watch Together',
        onTap: onWatchTogether,
        phaseTwo: true,
      ),
      _SettingsRow(
        icon: Icons.notifications_none,
        label: 'Notifications',
        onTap: onAccount,
      ),
      _SettingsRow(
        icon: Icons.lock_outline,
        label: 'Privacy & security',
        onTap: onAccount,
      ),
      _SettingsRow(
        icon: Icons.palette_outlined,
        label: 'App appearance',
        onTap: onAccount,
      ),
      _SettingsRow(
        icon: Icons.help_outline,
        label: 'Help & support',
        onTap: onAccount,
      ),
      _SettingsRow(
        icon: Icons.info_outline,
        label: 'About StreamCatch',
        onTap: onAccount,
      ),
      _SettingsRow(icon: Icons.logout, label: 'Sign out', onTap: onAccount),
    ],
  );
}

class _MessagesPage extends StatelessWidget {
  const _MessagesPage({required this.onConversation});
  final VoidCallback onConversation;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
    children: [
      const _Eyebrow('YOUR PEOPLE'),
      const SizedBox(height: 7),
      const Text(
        'Messages',
        style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 15),
      const TextField(
        decoration: InputDecoration(
          hintText: 'Search conversations',
          prefixIcon: Icon(Icons.search, color: _muted),
        ),
      ),
      const SizedBox(height: 12),
      _ConversationTile(
        initials: 'AM',
        name: 'Amara M.',
        preview: 'That ending was wild!',
        onTap: onConversation,
      ),
      _ConversationTile(
        initials: 'JD',
        name: 'Jordan D.',
        preview: 'Sent you a movie link',
        onTap: onConversation,
      ),
      _ConversationTile(
        initials: 'SC',
        name: 'StreamCatch Crew',
        preview: 'Friday watch party?',
        onTap: onConversation,
      ),
      _ConversationTile(
        initials: 'MK',
        name: 'Mina K.',
        preview: 'Thanks for the recommendation',
        onTap: onConversation,
      ),
      const SizedBox(height: 12),
      const Text(
        'PRIVATE MESSAGES, GROUP CHATS, MOVIE SHARING, HISTORY AND NOTIFICATIONS ARE PLANNED FOR PHASE 2.',
        style: TextStyle(color: _muted, fontSize: 9, height: 1.5),
      ),
    ],
  );
}

class _ConversationPage extends StatelessWidget {
  const _ConversationPage({
    required this.controller,
    required this.messages,
    required this.onSend,
    required this.onBack,
  });
  final TextEditingController controller;
  final List<String> messages;
  final VoidCallback onSend;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 18, 8),
        child: Row(
          children: [
            IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
            const CircleAvatar(
              radius: 16,
              backgroundColor: _purple,
              child: Text('AM', style: TextStyle(fontSize: 10)),
            ),
            const SizedBox(width: 9),
            const Text(
              'Amara M.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      const Divider(height: 1, color: _panelRaised),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _ChatBubble(
              text: 'Have you watched 28 Years Later yet?',
              sent: false,
            ),
            const SizedBox(height: 10),
            ...messages.map(
              (message) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ChatBubble(text: message, sent: true),
              ),
            ),
            const SizedBox(height: 5),
            const _SharedMovieCard(),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: 'Message…',
                  prefixIcon: Icon(Icons.add, color: _muted),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'Send message',
              onPressed: onSend,
              icon: const Icon(Icons.send_rounded),
              style: IconButton.styleFrom(backgroundColor: _orange),
            ),
          ],
        ),
      ),
    ],
  );
}

class _WatchTogetherPage extends StatelessWidget {
  const _WatchTogetherPage({required this.onRoom});
  final VoidCallback onRoom;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
    children: [
      const _Eyebrow('MOVIE NIGHT, TOGETHER'),
      const SizedBox(height: 6),
      const Text(
        'Watch Together',
        style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 13),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _purple,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FRIDAY WATCH PARTY',
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Movie night, together.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              'Invite friends. Sync playback. Chat while you watch.',
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
            const SizedBox(height: 13),
            _PrimaryButton(
              label: 'Preview a watch room',
              onPressed: onRoom,
              height: 38,
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      const _SectionHeader('Your rooms', actionText: '0'),
      const SizedBox(height: 10),
      const _EmptyState(
        icon: Icons.groups_outlined,
        title: 'No watch rooms yet',
        body: 'Private rooms and synchronized playback are part of the planned Phase 2 experience.',
      ),
      const SizedBox(height: 15),
      const Text(
        'Playback will work only with supported authorized sources or personal-library videos everyone has lawful access to.',
        style: TextStyle(color: _muted, fontSize: 10, height: 1.45),
      ),
    ],
  );
}

class _PhaseTwoPage extends StatelessWidget {
  const _PhaseTwoPage({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.icon,
  });
  final String eyebrow;
  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 43, color: _purple),
          const SizedBox(height: 14),
          _Eyebrow(eyebrow),
          const SizedBox(height: 7),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, height: 1.5, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.selectedIndex,
    required this.onSelect,
  });
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: const BoxDecoration(
        color: Color(0xFF151311),
        border: Border(top: BorderSide(color: Color(0xFF25211E))),
      ),
      child: Row(
        children: [
          _BottomNavItem(
            icon: Icons.home_outlined,
            label: 'Home',
            index: 0,
            selected: selectedIndex,
            onTap: onSelect,
          ),
          _BottomNavItem(
            icon: Icons.search_rounded,
            label: 'Search',
            index: 1,
            selected: selectedIndex,
            onTap: onSelect,
          ),
          _BottomNavItem(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chat',
            index: 2,
            selected: selectedIndex,
            onTap: onSelect,
          ),
          _BottomNavItem(
            icon: Icons.video_library_outlined,
            label: 'Library',
            index: 3,
            selected: selectedIndex,
            onTap: onSelect,
          ),
          _BottomNavItem(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            index: 4,
            selected: selectedIndex,
            onTap: onSelect,
          ),
        ],
      ),
    ),
  );
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final int index, selected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final active = selected == index;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(19),
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: active ? _orange : Colors.transparent,
            borderRadius: BorderRadius.circular(19),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: active ? Colors.white : _muted, size: 20),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: active ? Colors.white : _muted,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoviePoster extends StatelessWidget {
  const _MoviePoster({
    required this.title,
    required this.color,
    required this.image,
    required this.rating,
    required this.onTap,
  });
  final String title;
  final Color color;
  final int image;
  final String rating;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(7),
    onTap: onTap,
    child: Container(
      width: 118,
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: 118,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(7),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _demoStills[image],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [color, _panelRaised],
                        ),
                      ),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0x99000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 6,
                    bottom: 5,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFD166),
                          size: 11,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          rating,
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: .3,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            '2025 · Movie',
            style: TextStyle(fontSize: 8, color: _muted),
          ),
        ],
      ),
    ),
  );
}

class _SearchResult extends StatelessWidget {
  const _SearchResult({required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(vertical: 4),
    leading: Container(
      width: 45,
      height: 53,
      decoration: BoxDecoration(
        color: title == '28 Years Later' ? _purple : _panelRaised,
        borderRadius: BorderRadius.circular(6),
      ),
    ),
    title: Text(
      title,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    ),
    subtitle: const Text(
      'Movie  ·  2026  ·  Sci-Fi',
      style: TextStyle(color: _muted, fontSize: 10),
    ),
    trailing: const Icon(Icons.chevron_right, color: _muted, size: 18),
  );
}

class _LibraryTitle extends StatelessWidget {
  const _LibraryTitle({required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 82,
            decoration: BoxDecoration(
              color: title == '28 Years Later' ? _purple : _panelRaised,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Movie · Saved to your watchlist',
                  style: TextStyle(fontSize: 10, color: _muted),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: _muted, size: 18),
        ],
      ),
    ),
  );
}

class _DownloadPlaceholder extends StatelessWidget {
  const _DownloadPlaceholder({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: _panel,
      borderRadius: BorderRadius.circular(11),
    ),
    child: Row(
      children: [
        const Icon(Icons.download_done_outlined, size: 19, color: _muted),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: _muted, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.initials,
    required this.name,
    required this.preview,
    required this.onTap,
  });
  final String initials;
  final String name;
  final String preview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(vertical: 5),
    leading: CircleAvatar(
      backgroundColor: _purple,
      child: Text(initials, style: const TextStyle(fontSize: 10)),
    ),
    title: Text(
      name,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    ),
    subtitle: Text(
      preview,
      style: const TextStyle(color: _muted, fontSize: 10),
    ),
  );
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.text, required this.sent});
  final String text;
  final bool sent;

  @override
  Widget build(BuildContext context) => Align(
    alignment: sent ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      constraints: const BoxConstraints(maxWidth: 270),
      decoration: BoxDecoration(
        color: sent ? _orange : _panel,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: sent ? Colors.white : Colors.white70,
          fontSize: 11,
        ),
      ),
    ),
  );
}

class _SharedMovieCard extends StatelessWidget {
  const _SharedMovieCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(9),
    decoration: BoxDecoration(
      color: _panel,
      borderRadius: BorderRadius.circular(11),
    ),
    child: Row(
      children: [
        Container(
          width: 50,
          height: 58,
          decoration: BoxDecoration(
            color: _purple,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 9),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '28 YEARS LATER',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4),
            Text(
              'View movie details',
              style: TextStyle(color: _muted, fontSize: 9),
            ),
          ],
        ),
      ],
    ),
  );
}

class _CastPerson extends StatelessWidget {
  const _CastPerson({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const CircleAvatar(
        radius: 20,
        backgroundColor: _purple,
        child: Icon(Icons.person, size: 18, color: Colors.white70),
      ),
      const SizedBox(height: 5),
      Text(
        name,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 9, color: _muted),
      ),
    ],
  );
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: _panel,
    borderRadius: BorderRadius.circular(11),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          children: [
            Icon(icon, size: 17, color: _orange),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, size: 15, color: _muted),
          ],
        ),
      ),
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(
    this.title, {
    this.onAction,
    this.actionText = 'See all',
  });
  final String title;
  final VoidCallback? onAction;
  final String actionText;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      const Spacer(),
      if (onAction != null)
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionText,
            style: const TextStyle(
              color: _orange,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      if (onAction == null && actionText != 'See all')
        Text(actionText, style: const TextStyle(color: _muted, fontSize: 10)),
    ],
  );
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 8,
      letterSpacing: 1.4,
      color: _muted,
      fontWeight: FontWeight.w600,
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 8,
      letterSpacing: 1.2,
      color: _muted,
      fontWeight: FontWeight.w600,
    ),
  );
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.height = 43,
  });
  final String label;
  final VoidCallback onPressed;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    width: double.infinity,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: _orange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    ),
  );
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 40,
    width: double.infinity,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: _panel,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    ),
  );
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: _panel,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 10, color: Colors.white70),
    ),
  );
}

class _GenreTile extends StatelessWidget {
  const _GenreTile({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: _orange, size: 25),
      const SizedBox(height: 5),
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
    ],
  );
}

class _PillTab extends StatelessWidget {
  const _PillTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? _orange : _panel,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    ),
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.phaseTwo = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool phaseTwo;

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    dense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 1),
    leading: Icon(icon, size: 16, color: Colors.white70),
    title: Text(label, style: const TextStyle(fontSize: 11)),
    trailing: phaseTwo
        ? const Text(
            'PHASE 2',
            style: TextStyle(color: _muted, fontSize: 7, letterSpacing: .7),
          )
        : const Icon(Icons.chevron_right, size: 15, color: _muted),
  );
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(fontSize: 9, color: _muted)),
    ],
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 22),
    decoration: BoxDecoration(
      color: _panel,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Icon(icon, color: _muted, size: 24),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          body,
          textAlign: TextAlign.center,
          style: const TextStyle(color: _muted, fontSize: 10, height: 1.4),
        ),
      ],
    ),
  );
}
