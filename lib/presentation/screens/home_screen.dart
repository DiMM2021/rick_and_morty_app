import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubit/character_cubit.dart';
import '../widgets/character_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final PageStorageKey<String> _pageStorageKey = PageStorageKey("charactersList");

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  void _loadInitialData() {
    context.read<CharacterCubit>().resetPagination();
    context.read<CharacterCubit>().loadCharacters();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CharacterCubit>().loadCharacters(loadMore: true);
    }
  }

  Future<void> _refreshData() async {
    context.read<CharacterCubit>().resetPagination();
    await context.read<CharacterCubit>().loadCharacters();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Персонажи"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: BlocBuilder<CharacterCubit, CharacterState>(
        builder: (context, state) {
          if (state is CharacterInitial) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (state is CharacterLoading && state.characters.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (state is CharacterError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadInitialData,
                    child: Text("Повторить"),
                  ),
                ],
              ),
            );
          }
          
          if (state is CharacterLoaded) {
            return RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView.builder(
                key: _pageStorageKey,
                controller: _scrollController,
                itemCount: state.characters.length + (state.hasReachedMax ? 0 : 1),
                itemBuilder: (context, index) {
                  if (index >= state.characters.length) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: state.isOffline
                            ? Text("Нет подключения к интернету")
                            : CircularProgressIndicator(),
                      ),
                    );
                  }
                  return CharacterCard(character: state.characters[index]);
                },
              ),
            );
          }
          
          return Container();
        },
      ),
    );
  }
}