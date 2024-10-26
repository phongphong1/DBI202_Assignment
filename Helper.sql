USE DBI202_Assignment_PhongHV

--Tạo các View--
GO
CREATE VIEW ChucVuHienTai AS
SELECT n.MaNhanVien, n.HoTen, c.TenChucVu
FROM NhanVien n JOIN LSChucVu l on n.MaNhanVien = l.MaNhanVien
	JOIN ChucVu c on l.MaChucVu=c.MaChucVu
WHERE l.NgayKetThuc IS NULL;

GO
CREATE VIEW NoiCongTacHienTai AS
SELECT n.MaNhanVien, n.HoTen, q.TenCoQuan, p.TenPhongBan
FROM NhanVien n JOIN NoiCongTac ct on n.MaNhanVien=ct.MaNhanVien
			JOIN CoQuan q on q.MaCoQuan=ct.MaCoQuan
			LEFT JOIN PhongBan p on p.MaPhongBan = ct.MaPhongBan
WHERE ct.NgayKetThuc IS NULL;

--Tạo các Proc--
GO
CREATE PROC NhanVienTaiPhongBan
	@PhongBan NVARCHAR(100)
AS BEGIN
	SELECT n.MaNhanVien, n.HoTen, n.GioiTinh, n.SoDienThoai, n.DiaChi
	FROM NhanVien n JOIN NoiCongTac c on n.MaNhanVien=c.MaNhanVien
		JOIN PhongBan p on p.MaPhongBan=c.MaPhongBan
	WHERE p.TenPhongBan LIKE @PhongBan AND c.NgayKetThuc IS NULL
END;

GO
CREATE PROC NhanVienTaiCoQuan
	@CoQuan NVARCHAR(100)
AS BEGIN
	SELECT n.MaNhanVien, n.HoTen, n.GioiTinh, n.SoDienThoai, n.DiaChi
	FROM NhanVien n JOIN NoiCongTac c on n.MaNhanVien=c.MaNhanVien
		JOIN CoQuan q on q.MaCoQuan=c.MaCoQuan
	WHERE q.TenCoQuan LIKE @CoQuan AND c.NgayKetThuc IS NULL
END;

--Tạo các Function--
GO
CREATE FUNCTION SoNhanVienPhongBan(@PhongBan NVARCHAR(100))
RETURNS INT
AS BEGIN
	DECLARE @Count INT;
	SELECT @Count = COUNT(n.MaNhanVien) 
	FROM NoiCongTac n JOIN PhongBan p on n.MaPhongBan = p.MaPhongBan
	WHERE P.TenPhongBan LIKE @PhongBan AND n.NgayKetThuc IS NULL
	GROUP BY p.MaPhongBan
	RETURN @Count
END;

GO
CREATE FUNCTION SoNhanVienCoQuan(@CoQuan NVARCHAR(100))
RETURNS INT
AS BEGIN
	DECLARE @Count INT;
	SELECT @Count = COUNT(n.MaNhanVien) 
	FROM NoiCongTac n JOIN CoQuan q on n.MaCoQuan = q.MaCoQuan
	WHERE q.TenCoQuan LIKE @CoQuan AND n.NgayKetThuc IS NULL 
	GROUP BY q.MaCoQuan
	RETURN @Count
END;

--Tạo các Trigger--
GO
CREATE TRIGGER CapNhatLuong
ON Luong
INSTEAD OF INSERT
AS BEGIN
	DECLARE @MaNV int, @NgayCN DATE, @ML FLOAT, @NgayKT DATE
	SELECT @MaNV = MaNhanVien, @NgayCN = NgayCapNhat, @ML = MucLuong, @NgayKT = TinhDenNgay FROM inserted
	IF EXISTS (SELECT * FROM Luong WHERE MaNhanVien = @MaNV AND TinhDenNgay IS NULL) BEGIN
		IF (@NgayCN > (SELECT TOP 1 NgayCapNhat FROM Luong WHERE MaNhanVien = @MaNV AND TinhDenNgay IS NULL)) BEGIN
			UPDATE Luong SET TinhDenNgay = @NgayCN WHERE TinhDenNgay IS NULL AND MaNhanVien = @MaNV
			INSERT INTO Luong(MaNhanVien, MucLuong, NgayCapNhat, TinhDenNgay) VALUES
			(@MaNV, @ML, @NgayCN, @NgayKT)
		END
		ELSE
			PRINT 'Ngay cap nhat khong hop le'
	END
	ELSE
		INSERT INTO Luong(MaNhanVien, MucLuong, NgayCapNhat, TinhDenNgay) VALUES
			(@MaNV, @ML, @NgayCN, @NgayKT)
END;

GO
CREATE TRIGGER KiemTraSDTNhanVien
ON NhanVien
AFTER INSERT
AS 
BEGIN
    IF EXISTS (SELECT *
				FROM inserted
				WHERE SoDienThoai NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
    )BEGIN
        PRINT 'So dien thoai khong hop le';
        ROLLBACK TRANSACTION;
    END
END;

GO
CREATE TRIGGER KiemTraSDTPhongBan
ON PhongBan
AFTER INSERT
AS 
BEGIN
    IF EXISTS (SELECT *
				FROM inserted
				WHERE SDT NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
    )BEGIN
        PRINT 'So dien thoai khong hop le';
        ROLLBACK TRANSACTION;
    END
END;

