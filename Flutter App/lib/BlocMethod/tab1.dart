import 'package:demoapp/BlocMethod/app.dart';
import 'package:demoapp/BlocMethod/model.dart';
import 'package:demoapp/BlocMethod/model_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserProfileListTab1 extends StatefulWidget {
  const UserProfileListTab1({Key? key}) : super(key: key);

  @override
  State<UserProfileListTab1> createState() => _UserProfileListTab1State();
}

class _UserProfileListTab1State extends State<UserProfileListTab1> {
  bool isinitiated = false;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        if (!isLoad) {
          setState(() {});
        }
      }
    });
  }

  bool isLoad = false;
  Future getData() async {
    isLoad = true;
    await context.read<UserProfileCubit>().fetchUsers(10, isinitiated);
    isinitiated = true;
    isLoad = false;
  }

  Future onTap(UserProfile user) async {
    Utils(context).showLoading();
    Navigator.pop(context);
  }

  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        bool isLoading = snapshot.connectionState != ConnectionState.done;
        return Column(
          children: [
            Expanded(
                child: UserListBuilder(
                    scrollController: _scrollController,
                    isSelectedUser: false)),
            if (isLoading)
              const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Center(child: CircularProgressIndicator()))
          ],
        );
      },
    );
  }
}

class UserListBuilder extends StatelessWidget {
  final ScrollController scrollController;
  final bool isSelectedUser;
  const UserListBuilder(
      {Key? key, required this.scrollController, required this.isSelectedUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    late List<UserProfile> users;
    users = isSelectedUser
        ? context
            .select<UserProfileCubit, List<UserProfile>>((e) => e.selectedUsers)
        : context
            .select<UserProfileCubit, List<UserProfile>>((e) => e.fetchedUsers);
    final selecUsersIds =
        context.select<UserProfileCubit, List<String>>((e) => e.selecUsersIds);
    return users.isEmpty
        ? const SizedBox.shrink()
        : ListView.separated(
            key: const Key('ListViewKey'),
            separatorBuilder: (c, i) => const Divider(),
            controller: scrollController,
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (BuildContext context, i) {
              return UserProfileListTile(
                key: Key(users[i].id),
                user: users[i],
                isSelected: selecUsersIds.contains(users[i].id),
                onChanged: (v) async {
                  await context.read<UserProfileCubit>().onTap(users[i]);
                },
              );
            },
          );
  }
}
