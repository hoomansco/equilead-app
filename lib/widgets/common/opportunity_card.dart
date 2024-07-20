import 'package:flutter/material.dart';
import 'package:equilead/models/opportunity.dart';
import 'package:equilead/screens/opportunity/details.dart';
import 'package:equilead/widgets/animation/press_effect.dart';

class OpportunityCard extends StatelessWidget {
  const OpportunityCard({
    super.key,
    required this.opportunity,
  });

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PressEffect(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OpportunityDetails(
              opportunityId: opportunity.id!.toString(),
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 24, 0, 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  opportunity.companyName!,
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                SizedBox(
                  width: size.width * 0.68,
                  child: Text(
                    opportunity.title!,
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    softWrap: true,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '${opportunity.type} · ${opportunity.mode} ${opportunity.category != null ? "· ${opportunity.category}" : ""}',
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Spacer(),
            SizedBox(
              height: 40,
              width: 40,
              child: Image.network(opportunity.companyLogo!),
            ),
          ],
        ),
      ),
    );
  }
}
