-- ==========================================
-- MODUL 1: KATALOG PRODUK (3NF SUBTYPE PATTERN)
-- ==========================================

-- 1. Master Kategori Produk
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    slug VARCHAR(50) NOT NULL UNIQUE
);

-- 2. Products (Supertype - Atribut Universal)
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id INT NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    brand VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Subtype 1: Reagen / Bahan Kimia
CREATE TABLE chemical_attributes (
    product_id UUID PRIMARY KEY REFERENCES products(id) ON DELETE CASCADE,
    cas_number VARCHAR(20) NOT NULL UNIQUE,
    iupac_name VARCHAR(255),
    formula VARCHAR(100)
);

-- 4. Subtype 2: Alat Gelas Lab
CREATE TABLE glassware_attributes (
    product_id UUID PRIMARY KEY REFERENCES products(id) ON DELETE CASCADE,
    material VARCHAR(100) NOT NULL,
    glass_class VARCHAR(20),
    is_autoclavable BOOLEAN DEFAULT TRUE
);

-- 5. Subtype 3: Spare-part & Aksesori Instrumen
CREATE TABLE instrument_part_attributes (
    product_id UUID PRIMARY KEY REFERENCES products(id) ON DELETE CASCADE,
    instrument_type VARCHAR(100) NOT NULL,
    oem_part_number VARCHAR(100)
);

-- 6. Master Simbol/Bahaya GHS
CREATE TABLE ghs_hazards (
    id SERIAL PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL
);

-- 7. Junction Table: Relasi Reagen Kimia dengan Simbol GHS (N:M)
CREATE TABLE product_ghs_hazards (
    product_id UUID REFERENCES chemical_attributes(product_id) ON DELETE CASCADE,
    ghs_hazard_id INT REFERENCES ghs_hazards(id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, ghs_hazard_id)
);

-- 8. Varian Komersial Produk (Grade, Kemasan, Harga, Stok)
CREATE TABLE product_variants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    sku VARCHAR(100) NOT NULL UNIQUE,
    grade VARCHAR(50),
    packaging_size NUMERIC(10, 2),
    unit VARCHAR(20),
    price BIGINT NOT NULL CHECK (price >= 0),
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- MODUL 2: PENGGUNA & ALAMAT (AUTH & RBAC)
-- ==========================================

-- 9. Master Data User (Buyer & Admin)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(50),
    role VARCHAR(20) NOT NULL DEFAULT 'BUYER' CHECK (role IN ('BUYER', 'ADMIN')),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);

-- 10. Alamat Pengiriman User (1 to N)
CREATE TABLE user_addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    label VARCHAR(50) NOT NULL DEFAULT 'Utama',
    recipient_name VARCHAR(255) NOT NULL,
    recipient_phone VARCHAR(50) NOT NULL,
    institution_name VARCHAR(255),
    full_address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    province VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_addresses_user_id ON user_addresses(user_id);

-- ==========================================
-- MODUL 3: KERANJANG BELANJA (CART SUBSYSTEM)
-- ==========================================

-- 11. Keranjang Belanja Aktif User (1 User = 1 Active Cart)
CREATE TABLE carts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 12. Item Keranjang
CREATE TABLE cart_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cart_id UUID NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
    product_variant_id UUID NOT NULL REFERENCES product_variants(id) ON DELETE CASCADE,
    quantity INT NOT NULL CHECK (quantity > 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(cart_id, product_variant_id)
);

-- ==========================================
-- MODUL 4: TRANSAKSI & PEMBAYARAN (ORDER SUBSYSTEM)
-- ==========================================

-- 13. Header Pesanan (Order Header + Shipping Snapshot)
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number VARCHAR(50) NOT NULL UNIQUE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING_PAYMENT'
        CHECK (status IN ('PENDING_PAYMENT', 'PAID', 'PROCESSING', 'SHIPPED', 'COMPLETED', 'CANCELLED', 'EXPIRED')),
    total_amount BIGINT NOT NULL CHECK (total_amount >= 0),

    -- Snapshot Alamat Pengiriman
    shipping_recipient_name VARCHAR(255) NOT NULL,
    shipping_recipient_phone VARCHAR(50) NOT NULL,
    shipping_institution_name VARCHAR(255),
    shipping_full_address TEXT NOT NULL,
    shipping_city VARCHAR(100) NOT NULL,
    shipping_province VARCHAR(100) NOT NULL,
    shipping_postal_code VARCHAR(20) NOT NULL,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);

-- 14. Detail Item Pesanan (Order Item Snapshot)
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_variant_id UUID REFERENCES product_variants(id) ON DELETE SET NULL,

    -- Snapshot Detail Produk & Varian saat Dibeli
    product_name VARCHAR(255) NOT NULL,
    variant_sku VARCHAR(100) NOT NULL,
    variant_details VARCHAR(255) NOT NULL,
    price_at_purchase BIGINT NOT NULL CHECK (price_at_purchase >= 0),
    quantity INT NOT NULL CHECK (quantity > 0),
    subtotal BIGINT NOT NULL CHECK (subtotal >= 0)
);

-- 15. Catatan Pembayaran & Callback Gateway
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL UNIQUE REFERENCES orders(id) ON DELETE CASCADE,
    gateway_transaction_id VARCHAR(255),
    payment_type VARCHAR(50),
    amount BIGINT NOT NULL CHECK (amount >= 0),
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING'
        CHECK (status IN ('PENDING', 'SETTLEMENT', 'EXPIRED', 'CANCELLED', 'FAILED')),
    raw_response JSONB,
    paid_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);