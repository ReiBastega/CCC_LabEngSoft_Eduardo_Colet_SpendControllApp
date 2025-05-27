import 'package:flutter/material.dart';
import 'package:spend_controll/modules/Groups/model/group_model.dart';

class GroupListWidget extends StatelessWidget {
  final List<Group> groups;
  final Function(Group) onGroupTap;

  const GroupListWidget({
    super.key,
    required this.groups,
    required this.onGroupTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return _buildGroupCard(context, group);
        },
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, Group group) {
    return GestureDetector(
      onTap: () => onGroupTap(group),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        group.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.circle,
                      size: 12,
                      color: group.isPositive ? Colors.green : Colors.red,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  'R\$ ${group.balance.abs().toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: group.isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${group.memberCount} ${group.memberCount == 1 ? 'membro' : 'membros'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
