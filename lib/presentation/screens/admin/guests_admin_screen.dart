import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roomore_hotels_test/cubits/guests/guests_cubit.dart';
import 'package:roomore_hotels_test/data/repositories/guest_repository.dart';
import 'package:roomore_hotels_test/utils/ui.dart';

class GuestsAdminScreen extends StatelessWidget {
  static const routeName = '/admin/guests';
  final String hotelId;
  const GuestsAdminScreen({super.key, required this.hotelId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GuestsCubit(GuestRepository())..load(hotelId: hotelId),
      child: Scaffold(
        appBar: AppBar(title: Text(tr('admin.guests.title'))),
        body: Builder(
          builder: (inner) => RefreshIndicator(
            onRefresh: () async {
              await inner.read<GuestsCubit>().load(hotelId: hotelId);
              if (!inner.mounted) return;
              final err = inner.read<GuestsCubit>().state.error;
              showSuccessSnack(inner, err ?? tr('common.refreshed'));
            },
            child: BlocBuilder<GuestsCubit, GuestsState>(
              builder: (context, state) {
                if (state.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.error != null) {
                  return Center(child: Text(state.error!));
                }
                if (state.list.isEmpty) {
                  return Center(child: Text(tr('common.noItems')));
                }
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: state.list.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final g = state.list[i];
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person_outline),
                      ),
                      title: Text(g.fullName.isEmpty ? '-' : g.fullName),
                      subtitle: Text(
                        [
                          g.email,
                          g.phone,
                        ].where((e) => e.isNotEmpty).join(' · '),
                      ),
                      onTap: () async {
                        final res = await Navigator.of(context).pushNamed(
                          '/admin/guests/details',
                          arguments: {'guest': g, 'hotelId': hotelId},
                        );
                        if (!context.mounted) return;
                        if (res is Map &&
                            (res['updated'] != null ||
                                res['deleted'] == true)) {
                          context.read<GuestsCubit>().load(hotelId: hotelId);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
        floatingActionButton: Builder(
          builder: (inner) => FloatingActionButton(
            onPressed: () async {
              final created = await Navigator.of(
                inner,
              ).pushNamed('/admin/guests/add', arguments: {'hotelId': hotelId});
              if (!inner.mounted) return;
              if (created == true) {
                inner.read<GuestsCubit>().load(hotelId: hotelId);
              }
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
