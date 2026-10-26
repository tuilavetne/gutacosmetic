import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import 'restock_requests_tab.dart';
import 'returns_transfers_tabs.dart';
import 'stock_history_tab.dart';
import 'stock_logs_tabs.dart';
import 'stock_overview_tab.dart';

/// Màn Kho dùng chung của Manager: tồn kho, đề xuất nhập, phiếu nhập, ghi
/// giảm, trả hàng lỗi, hàng chuyển đến và lịch sử kho.
class ManagerStockScreen extends StatelessWidget {
  const ManagerStockScreen({super.key});

  static const tabs = [
    (label: 'Tồn kho', page: StockOverviewTab()),
    (label: 'Đề xuất nhập', page: RestockRequestsTab()),
    (label: 'Phiếu nhập', page: ReceiptsTab()),
    (label: 'Ghi giảm', page: AdjustmentsTab()),
    (label: 'Trả hàng lỗi', page: ReturnRequestsTab()),
    (label: 'Hàng chuyển đến', page: IncomingTransfersTab()),
    (label: 'Lịch sử', page: StockHistoryTab()),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: ColoredBox(
        color: AppColors.background,
        child: Column(
          children: [
            ColoredBox(
              color: Colors.white,
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppColors.primary,
                indicatorColor: AppColors.primary,
                unselectedLabelColor: AppColors.muted,
                tabs: [for (final tab in tabs) Tab(text: tab.label)],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: TabBarView(
                    children: [for (final tab in tabs) tab.page],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
