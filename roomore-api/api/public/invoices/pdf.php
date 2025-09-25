<?php
require_once __DIR__ . '/../../_bootstrap.php';
json_response(501, [
  'error' => 'pdf_not_supported',
  'message' => 'PDF generation is handled on the client app.'
]);

// use Mpdf\Mpdf;
// use Mpdf\Config\ConfigVariables;
// use Mpdf\Config\FontVariables;
// use Mpdf\Output\Destination;

// // -------- Params --------
// $lang = strtolower($_GET['lang'] ?? $_POST['lang'] ?? 'ar');
// $hotelCode = $_GET['hotel_code'] ?? $_POST['hotel_code'] ??
//              $_GET['code'] ?? $_POST['code'] ??
//              ($_SERVER['HTTP_X_HOTEL_CODE'] ?? null);

// $email = $_GET['email'] ?? $_POST['email'] ?? null;
// $phone = $_GET['phone'] ?? $_POST['phone'] ?? null;
// $token = $_GET['token'] ?? $_POST['token'] ?? null;

// $invoiceId = $_GET['invoice_id'] ?? $_POST['invoice_id'] ?? null;
// $number    = $_GET['number'] ?? $_POST['number'] ?? null;

// $disposition = strtolower($_GET['disposition'] ?? $_POST['disposition'] ?? 'inline'); // inline | download

// // -------- Messages --------
// $M = [
//   'ar' => [
//     'missing_hotel'    => 'مطلوب hotel_code',
//     'missing_identity' => 'مطلوب بريد أو جوال أو رمز التحقق',
//     'missing_invoice'  => 'مطلوب invoice_id أو number',
//     'not_found_guest'  => 'لم يتم العثور على النزيل',
//     'not_found_invoice'=> 'لم يتم العثور على الفاتورة',
//     'hotel' => 'الفندق',
//     'guest' => 'الضيف',
//     'invoice' => 'فاتورة',
//     'number' => 'رقم',
//     'date' => 'التاريخ',
//     'status' => 'الحالة',
//     'booking' => 'الحجز',
//     'items' => 'العناصر',
//     'desc' => 'الوصف',
//     'qty' => 'الكمية',
//     'unit_price' => 'سعر الوحدة',
//     'line_total' => 'الإجمالي',
//     'subtotal' => 'الإجمالي الفرعي',
//     'tax' => 'الضريبة',
//     'total' => 'الإجمالي الكلي',
//     'currency' => 'العملة',
//     'notes' => 'ملاحظات',
//   ],
//   'en' => [
//     'missing_hotel'    => 'hotel_code is required',
//     'missing_identity' => 'Email, phone, or token is required',
//     'missing_invoice'  => 'invoice_id or number is required',
//     'not_found_guest'  => 'Guest not found',
//     'not_found_invoice'=> 'Invoice not found',
//     'hotel' => 'Hotel',
//     'guest' => 'Guest',
//     'invoice' => 'Invoice',
//     'number' => 'Number',
//     'date' => 'Date',
//     'status' => 'Status',
//     'booking' => 'Booking',
//     'items' => 'Items',
//     'desc' => 'Description',
//     'qty' => 'Qty',
//     'unit_price' => 'Unit Price',
//     'line_total' => 'Line Total',
//     'subtotal' => 'Subtotal',
//     'tax' => 'Tax',
//     'total' => 'Total',
//     'currency' => 'Currency',
//     'notes' => 'Notes',
//   ],
// ];
// $T = $M[$lang] ?? $M['ar'];

// // -------- Validations --------
// try {
//   if (!$hotelCode) { http_response_code(422); echo json_encode(['error'=>$T['missing_hotel']], JSON_UNESCAPED_UNICODE); exit; }
//   if (!$email && !$phone && !$token) { http_response_code(422); echo json_encode(['error'=>$T['missing_identity']], JSON_UNESCAPED_UNICODE); exit; }
//   if (!$invoiceId && !$number) { http_response_code(422); echo json_encode(['error'=>$T['missing_invoice']], JSON_UNESCAPED_UNICODE); exit; }

//   // -------- Guest --------
//   $gst = $pdo->prepare("SELECT id, name_en, name_ar, email, phone
//                         FROM guests
//                         WHERE hotel_code=:hotel AND (
//                           (:email IS NOT NULL AND email=:email) OR
//                           (:phone IS NOT NULL AND phone=:phone) OR
//                           (:token IS NOT NULL AND verify_token=:token)
//                         ) LIMIT 1");
//   $gst->execute([':hotel'=>$hotelCode, ':email'=>$email, ':phone'=>$phone, ':token'=>$token]);
//   $guest = $gst->fetch();
//   if (!$guest) { http_response_code(404); echo json_encode(['error'=>$T['not_found_guest']], JSON_UNESCAPED_UNICODE); exit; }

//   // -------- Hotel info (اختياري للترويسة) --------
//   $hst = $pdo->prepare("SELECT id, name, slug, city FROM hotels WHERE slug=:slug LIMIT 1");
//   $hst->execute([':slug'=>$hotelCode]);
//   $hotel = $hst->fetch() ?: ['name' => $hotelCode, 'city' => ''];

//   // -------- Invoice + Booking --------
//   $cond = $invoiceId ? 'i.id = :x' : 'i.number = :x';
//   $sql = "SELECT i.*, b.booking_code, b.currency AS booking_currency
//           FROM invoices i
//           INNER JOIN bookings b ON b.id = i.booking_id
//           WHERE i.hotel_code=:hotel AND b.guest_id=:gid AND $cond
//           LIMIT 1";
//   $ist = $pdo->prepare($sql);
//   $ist->execute([':hotel'=>$hotelCode, ':gid'=>$guest['id'], ':x'=>($invoiceId ?: $number)]);
//   $inv = $ist->fetch();
//   if (!$inv) { http_response_code(404); echo json_encode(['error'=>$T['not_found_invoice']], JSON_UNESCAPED_UNICODE); exit; }

//   // -------- Items --------
//   $it = $pdo->prepare("SELECT id, description_en, description_ar, qty, unit_price, total, sort_order
//                        FROM invoice_items WHERE invoice_id=:iid
//                        ORDER BY sort_order ASC, id ASC");
//   $it->execute([':iid'=>$inv['id']]);
//   $items = $it->fetchAll();

//   // -------- HTML (بسيط وأنيق) --------
//   $isArabic = ($lang === 'ar');
//   $dir = $isArabic ? 'rtl' : 'ltr';
//   $alignLeft = $isArabic ? 'right' : 'left';
//   $alignRight = $isArabic ? 'left' : 'right';

//   $guestName = $isArabic ? ($guest['name_ar'] ?: $guest['name_en']) : ($guest['name_en'] ?: $guest['name_ar']);
//   $currency  = $inv['currency'] ?: ($inv['booking_currency'] ?: 'SAR');

//   $rowsHtml = '';
//   foreach ($items as $line) {
//     $desc = $isArabic ? ($line['description_ar'] ?: $line['description_en']) : ($line['description_en'] ?: $line['description_ar']);
//     $rowsHtml .= "<tr>
//       <td style='padding:8px;border:1px solid #ddd;'>{$desc}</td>
//       <td style='padding:8px;border:1px solid #ddd; text-align:center;'>".number_format((float)$line['qty'],2)."</td>
//       <td style='padding:8px;border:1px solid #ddd; text-align:center;'>".number_format((float)$line['unit_price'],2)." {$currency}</td>
//       <td style='padding:8px;border:1px solid #ddd; text-align:center;'>".number_format((float)$line['total'],2)." {$currency}</td>
//     </tr>";
//   }

//   $notes = $isArabic ? ($inv['notes_ar'] ?? '') : ($inv['notes_en'] ?? '');

//   $html = "
//   <html dir='{$dir}'>
//   <head>
//     <meta charset='utf-8'>
//     <style>
//       body { font-family: DejaVu Sans, Arial, sans-serif; font-size: 12px; }
//       h1,h2,h3 { margin: 0; }
//       .muted { color:#666; font-size: 11px; }
//       .header { width:100%; margin-bottom:16px; }
//       .cell { padding:6px 8px; }
//       .box { border:1px solid #ddd; border-radius:6px; padding:10px; margin:8px 0; }
//       table { border-collapse: collapse; width:100%; }
//       .totals td { padding:6px 8px; }
//     </style>
//   </head>
//   <body>
//     <table class='header'>
//       <tr>
//         <td style='vertical-align:top; {$alignLeft}:0'>
//           <h2>".htmlspecialchars($hotel['name'])."</h2>
//           <div class='muted'>".htmlspecialchars($hotel['city'] ?? '')."</div>
//         </td>
//         <td style='text-align: {$alignRight}; vertical-align:top'>
//           <h2>{$T['invoice']}</h2>
//           <div>{$T['number']}: ".htmlspecialchars($inv['number'])."</div>
//           <div>{$T['date']}: ".date('Y-m-d', strtotime($inv['created_at'] ?? 'now'))."</div>
//           <div>{$T['status']}: ".htmlspecialchars($inv['status'])."</div>
//         </td>
//       </tr>
//     </table>

//     <div class='box'>
//       <table style='width:100%'>
//         <tr>
//           <td class='cell'><strong>{$T['guest']}</strong>: ".htmlspecialchars($guestName)."</td>
//           <td class='cell'><strong>{$T['booking']}</strong>: ".htmlspecialchars($inv['booking_code'])."</td>
//         </tr>
//         <tr>
//           <td class='cell'>Email: ".htmlspecialchars($guest['email'])."</td>
//           <td class='cell'>Phone: ".htmlspecialchars($guest['phone'])."</td>
//         </tr>
//       </table>
//     </div>

//     <h3 style='margin:12px 0'>{$T['items']}</h3>
//     <table>
//       <thead>
//         <tr>
//           <th style='padding:8px;border:1px solid #ddd;'>{$T['desc']}</th>
//           <th style='padding:8px;border:1px solid #ddd; text-align:center;'>{$T['qty']}</th>
//           <th style='padding:8px;border:1px solid #ddd; text-align:center;'>{$T['unit_price']}</th>
//           <th style='padding:8px;border:1px solid #ddd; text-align:center;'>{$T['line_total']}</th>
//         </tr>
//       </thead>
//       <tbody>
//         {$rowsHtml}
//       </tbody>
//     </table>

//     <table class='totals' style='margin-top:14px; width:50%; {$alignRight}:0; float: {$alignRight};'>
//       <tr>
//         <td>{$T['subtotal']}</td>
//         <td style='text-align: {$alignRight};'>".number_format((float)$inv['subtotal'], 2)." {$currency}</td>
//       </tr>
//       <tr>
//         <td>{$T['tax']}</td>
//         <td style='text-align: {$alignRight};'>".number_format((float)$inv['tax_amount'], 2)." {$currency}</td>
//       </tr>
//       <tr>
//         <td><strong>{$T['total']}</strong></td>
//         <td style='text-align: {$alignRight};'><strong>".number_format((float)$inv['total'], 2)." {$currency}</strong></td>
//       </tr>
//     </table>
//     <div style='clear:both'></div>

//     ".($notes ? "<div class='box'><strong>{$T['notes']}:</strong><br>".nl2br(htmlspecialchars($notes))."</div>" : "")."
//   </body>
//   </html>
//   ";

//   // -------- mPDF setup --------
//   if (!class_exists('\\Mpdf\\Mpdf')) {
//     http_response_code(500);
//     echo json_encode(['error' => 'mPDF library is not installed. Run: composer require mpdf/mpdf'], JSON_UNESCAPED_UNICODE);
//     exit;
//   }

//   // لتفعيل RTL واختيار خطوط تلقائية
//   $mpdf = new Mpdf([
//     'mode' => 'utf-8',
//     'format' => 'A4',
//     'margin_left' => 12,
//     'margin_right' => 12,
//     'margin_top' => 12,
//     'margin_bottom' => 12,
//   ]);
//   $mpdf->autoScriptToLang = true;
//   $mpdf->autoLangToFont = true;
//   if ($isArabic) { $mpdf->SetDirectionality('rtl'); }

//   $mpdf->WriteHTML($html);

//   $filename = 'invoice-'.preg_replace('/[^A-Za-z0-9\-_.]+/','-',$inv['number']).'.pdf';
// if ($disposition === 'download') {
//   $mpdf->Output($filename, Destination::DOWNLOAD);
// } else {
//   $mpdf->Output($filename, Destination::INLINE);
// }

// } catch (Throwable $e) {
//   http_response_code(500);
//   echo json_encode(['error'=>$e->getMessage()], JSON_UNESCAPED_UNICODE);
// }
