--Hiển thị những nhân viên làm việc tại Sở Y Tế--
SELECT n.MaNhanVien, n.HoTen, n.GioiTinh, n.NgaySinh, n.SoDienThoai, n.DiaChi
FROM NhanVien n JOIN NoiCongTac c ON n.MaNhanVien = c.MaNhanVien
				LEFT JOIN CoQuan q ON c.MaCoQuan = q.MaCoQuan
WHERE q.TenCoQuan = N'Sở Y Tế' AND c.NgayKetThuc IS NULL;

--Hiển thị toàn bộ nhân viên sắp xếp theo tên--
SELECT *
FROM NhanVien
ORDER BY HoTen

