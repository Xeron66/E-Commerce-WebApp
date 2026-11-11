-- 1. Extensions & Enums
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Users & Profiles
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    phone VARCHAR(11),
    password_hash TEXT NOT NULL,
    email_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE,
    account_status VARCHAR(30) DEFAULT 'active'
);

CREATE TABLE user_profiles (
    profile_id BIGSERIAL PRIMARY KEY,
    user_id UUID UNIQUE NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    first_name TEXT,
    last_name TEXT,
    profile_picture TEXT,
    date_of_birth DATE,
    gender VARCHAR(20)
);

CREATE TABLE user_addresses (
    address_id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    address_type VARCHAR(50),
    street_address TEXT,
    city TEXT,
    postal_code VARCHAR(20),
    is_default BOOLEAN DEFAULT false
);

-- 3. Roles & Permissions (Internal lookups use BIGSERIAL/BIGINT)
CREATE TABLE roles (
    role_id BIGSERIAL PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE permissions (
    permission_id BIGSERIAL PRIMARY KEY,
    permission_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE user_roles (
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    role_id BIGINT NOT NULL REFERENCES roles(role_id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE role_permissions (
    role_id BIGINT NOT NULL REFERENCES roles(role_id) ON DELETE CASCADE,
    permission_id BIGINT NOT NULL REFERENCES permissions(permission_id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

-- 4. Products & Catalog
CREATE TABLE categories (
    category_id BIGSERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    parent_id BIGINT REFERENCES categories(category_id)
);

CREATE TABLE products (
    product_id BIGSERIAL PRIMARY KEY,
    category_id BIGINT NOT NULL REFERENCES categories(category_id),
    product_name TEXT NOT NULL,
    description TEXT,
    brand_name TEXT,
    status VARCHAR(30) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE product_image (
    image_id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    is_primary BOOLEAN DEFAULT false,
    display_order INT DEFAULT 0
);

CREATE TABLE sizes (
    size_id BIGSERIAL PRIMARY KEY,
    size_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE colors (
    color_id BIGSERIAL PRIMARY KEY,
    color_name VARCHAR(50) UNIQUE NOT NULL,
    hex_code VARCHAR(10)
);

CREATE TABLE product_variants (
    variant_id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    size_id BIGINT NOT NULL REFERENCES sizes(size_id),
    color_id BIGINT NOT NULL REFERENCES colors(color_id),
    sku_code VARCHAR(100) UNIQUE,
    unit_price DECIMAL(12,2) NOT NULL,
    UNIQUE(product_id, size_id, color_id) -- Prevents duplicate size/color combos
);

-- 5. Inventory
CREATE TABLE inventory (
    inventory_id BIGSERIAL PRIMARY KEY,
    variant_id BIGINT NOT NULL REFERENCES product_variants(variant_id) ON DELETE CASCADE,
    quantity BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE inventory_movements (
    movement_id BIGSERIAL PRIMARY KEY,
    variant_id BIGINT NOT NULL REFERENCES product_variants(variant_id) ON DELETE CASCADE,
    movement_type VARCHAR(30) NOT NULL, -- e.g., 'sale', 'restock', 'return'
    quantity BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. Carts
CREATE TABLE carts (
    cart_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cart_items (
    cart_item_id BIGSERIAL PRIMARY KEY,
    cart_id UUID NOT NULL REFERENCES carts(cart_id) ON DELETE CASCADE,
    variant_id BIGINT NOT NULL REFERENCES product_variants(variant_id) ON DELETE CASCADE,
    quantity BIGINT NOT NULL DEFAULT 1,
    UNIQUE(cart_id, variant_id) -- Prevents adding the exact same variant as two separate rows
);

-- 7. Orders & Payments
CREATE TABLE orders (
    order_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    sub_total DECIMAL(12,2) NOT NULL,
    discount_amount DECIMAL(12,2) DEFAULT 0.00,
    shipping_cost DECIMAL(12,2) DEFAULT 0.00,
    total_amount DECIMAL(12,2) NOT NULL,
    payment_status BOOLEAN DEFAULT false,
    order_status VARCHAR(30) DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE order_items (
    order_items_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    variant_id BIGINT NOT NULL REFERENCES product_variants(variant_id),
    sku VARCHAR(100),
    size_name VARCHAR(50),
    color_name VARCHAR(50),
    unit_price DECIMAL(12,2) NOT NULL,
    quantity BIGINT NOT NULL CHECK (quantity > 0),
    subtotal DECIMAL(12,2) NOT NULL
);

CREATE TABLE payments (
    payment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    payment_method VARCHAR(50),
    transaction_id VARCHAR(100),
    amount DECIMAL(12,2) NOT NULL,
    payment_status VARCHAR(30) DEFAULT 'pending',
    paid_at TIMESTAMP WITH TIME ZONE
);

-- 8. Promotions
CREATE TABLE promotions (
    promotion_id BIGSERIAL PRIMARY KEY,
    promotion_name VARCHAR(100) NOT NULL,
    description TEXT,
    discount_type VARCHAR(20) NOT NULL,
    discount_value DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'active',
    start_date DATE,
    end_date DATE,
    created_by UUID NOT NULL REFERENCES users(user_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE promotion_products (
    promotion_id BIGINT NOT NULL REFERENCES promotions(promotion_id) ON DELETE CASCADE,
    product_id BIGINT NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    PRIMARY KEY (promotion_id, product_id)
);

-- 9. Support & Admin
CREATE TABLE support_tickets (
    ticket_id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(user_id),
    assigned_to UUID REFERENCES users(user_id),
    subject TEXT NOT NULL,
    description TEXT NOT NULL,
    support_status VARCHAR(30) DEFAULT 'open',
    support_priority VARCHAR(20) DEFAULT 'medium',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE ticket_messages (
    message_id BIGSERIAL PRIMARY KEY,
    ticket_id BIGINT NOT NULL REFERENCES support_tickets(ticket_id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(user_id),
    message TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE change_requests (
    request_id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(user_id),
    requested_by UUID NOT NULL REFERENCES users(user_id),
    reviewed_by UUID REFERENCES users(user_id),
    entity_type VARCHAR(50) NOT NULL,
    entity_id BIGINT,
    old_values JSONB,
    proposed_values JSONB NOT NULL,
    change_status VARCHAR(30) DEFAULT 'pending',
    reason TEXT,
    requested_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP WITH TIME ZONE
);