USE `zero_waste_db`;

-- Categorías
INSERT INTO categories (uuid, code, name_es, name_en) VALUES
 (UUID(), 'bebidas', 'Bebidas', 'Drinks'),
 (UUID(), 'entrantes', 'Entrantes', 'Starters'),
 (UUID(), 'principales', 'Principales', 'Mains'),
 (UUID(), 'postres', 'Postres', 'Desserts')
ON DUPLICATE KEY UPDATE name_es=VALUES(name_es), name_en=VALUES(name_en);

-- Alérgenos mínimos (ejemplo)
INSERT INTO allergens (code, name_es, name_en) VALUES
 ('gluten','Gluten','Gluten'),
 ('lactose','Lactosa','Lactose'),
 ('nuts','Frutos secos','Nuts')
ON DUPLICATE KEY UPDATE name_es=VALUES(name_es), name_en=VALUES(name_en);

-- Venue + horario demo
INSERT INTO venues (uuid, code, name) VALUES (UUID(), 'CENTRO', 'Restaurante Centro')
ON DUPLICATE KEY UPDATE name=VALUES(name);

INSERT INTO opening_hours (venue_id, weekday, open_time, close_time)
SELECT v.id, d.wd, '12:00:00', '23:00:00'
FROM venues v
JOIN (SELECT 0 wd UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6) d
ON v.code='CENTRO'
ON DUPLICATE KEY UPDATE open_time=VALUES(open_time), close_time=VALUES(close_time);

-- 24 productos zero-waste (6 por categoría)
-- Bebidas
INSERT INTO products (uuid, category_id, name_es, name_en, description_es, description_en, price, is_vegan, barcode)
SELECT UUID(), c.id, 'Agua filtrada', 'Filtered water', 'Agua de filtración, sin plástico.', 'Filtered water, no plastic.', 1.20, 1, '100000001' FROM categories c WHERE c.code='bebidas'
UNION ALL SELECT UUID(), c.id, 'Kombucha casera', 'House kombucha', 'Fermentada con excedente de fruta.', 'Fermented using surplus fruit.', 3.50, 1, '100000002' FROM categories c WHERE c.code='bebidas'
UNION ALL SELECT UUID(), c.id, 'Infusión de pieles cítricas', 'Citrus peels infusion', 'Aprovecha cáscaras de cítricos.', 'Uses citrus peels leftovers.', 2.20, 1, '100000003' FROM categories c WHERE c.code='bebidas'
UNION ALL SELECT UUID(), c.id, 'Agua con hierbas del huerto', 'Herbal garden water', 'Hierbas de temporada.', 'Seasonal herbs.', 1.80, 1, '100000004' FROM categories c WHERE c.code='bebidas'
UNION ALL SELECT UUID(), c.id, 'Limonada de temporada', 'Seasonal lemonade', 'Limón y menta del día.', 'Daily lemon & mint.', 2.50, 1, '100000005' FROM categories c WHERE c.code='bebidas'
UNION ALL SELECT UUID(), c.id, 'Té frío reutilizado', 'Cold brew tea reuse', 'Segunda extracción.', 'Second extraction.', 2.00, 1, '100000006' FROM categories c WHERE c.code='bebidas';

-- Entrantes
INSERT INTO products (uuid, category_id, name_es, name_en, description_es, description_en, price, is_vegan, barcode)
SELECT UUID(), c.id, 'Crema de verduras del día', 'Daily veggie cream', 'Verduras de temporada y excedentes.', 'Seasonal & surplus veggies.', 4.90, 1, '200000001' FROM categories c WHERE c.code='entrantes'
UNION ALL SELECT UUID(), c.id, 'Tostada de pan del día', 'Day-old bread toast', 'Pan de ayer con pesto de hojas.', 'Day-old bread with leaf pesto.', 3.80, 1, '200000002' FROM categories c WHERE c.code='entrantes'
UNION ALL SELECT UUID(), c.id, 'Croquetas de aprovechamiento', 'Zero-waste croquettes', 'Relleno con recortes de verduras.', 'Filled with veggie trimmings.', 5.20, 0, '200000003' FROM categories c WHERE c.code='entrantes'
UNION ALL SELECT UUID(), c.id, 'Ensalada tallos & hojas', 'Stems & leaves salad', 'Usa tallos/hierbas que sobran.', 'Uses leftover stems/herbs.', 5.50, 1, '200000004' FROM categories c WHERE c.code='entrantes'
UNION ALL SELECT UUID(), c.id, 'Hummus de legumbre del día', 'Daily legume hummus', 'Lote de legumbre del servicio.', 'Service batch legume.', 4.50, 1, '200000005' FROM categories c WHERE c.code='entrantes'
UNION ALL SELECT UUID(), c.id, 'Tortilla de recortes', 'Scrap omelette', 'Huevos + recortes de verduras.', 'Eggs + veggie scraps.', 4.80, 0, '200000006' FROM categories c WHERE c.code='entrantes';

-- Principales
INSERT INTO products (uuid, category_id, name_es, name_en, description_es, description_en, price, is_vegan, barcode)
SELECT UUID(), c.id, 'Arroz de temporada', 'Seasonal rice', 'Caldo con restos de verduras.', 'Broth from veggie leftovers.', 9.50, 0, '300000001' FROM categories c WHERE c.code='principales'
UNION ALL SELECT UUID(), c.id, 'Pasta al pesto de hojas', 'Leaf pesto pasta', 'Pesto de hojas excedentes.', 'Pesto from surplus leaves.', 8.90, 1, '300000002' FROM categories c WHERE c.code='principales'
UNION ALL SELECT UUID(), c.id, 'Curry de recortes', 'Scraps curry', 'Piezas variadas del día.', 'Mixed daily pieces.', 9.80, 1, '300000003' FROM categories c WHERE c.code='principales'
UNION ALL SELECT UUID(), c.id, 'Hamburguesa veggie del día', 'Veggie burger of the day', 'Aprovecha cocción previa.', 'Uses prior cook batch.', 10.50, 1, '300000004' FROM categories c WHERE c.code='principales'
UNION ALL SELECT UUID(), c.id, 'Frittata antidesperdicio', 'Zero-waste frittata', 'Huevos + verduras excedentes.', 'Eggs + surplus veggies.', 8.70, 0, '300000005' FROM categories c WHERE c.code='principales'
UNION ALL SELECT UUID(), c.id, 'Wok de tallos', 'Stems wok', 'Cocina rápida de tallos.', 'Quick-cooked stems.', 8.30, 1, '300000006' FROM categories c WHERE c.code='principales';

-- Postres
INSERT INTO products (uuid, category_id, name_es, name_en, description_es, description_en, price, is_vegan, barcode)
SELECT UUID(), c.id, 'Pudin de pan', 'Bread pudding', 'Pan de ayer, canela.', 'Day-old bread & cinnamon.', 4.20, 0, '400000001' FROM categories c WHERE c.code='postres'
UNION ALL SELECT UUID(), c.id, 'Compota de fruta madura', 'Ripe fruit compote', 'Fruta muy madura.', 'Very ripe fruit.', 3.80, 1, '400000002' FROM categories c WHERE c.code='postres'
UNION ALL SELECT UUID(), c.id, 'Brownie cacao sostenible', 'Sustainable cocoa brownie', 'Merma de chocolate.', 'Chocolate trimming.', 4.90, 0, '400000003' FROM categories c WHERE c.code='postres'
UNION ALL SELECT UUID(), c.id, 'Granola casera', 'House granola', 'Avena y frutos secos sueltos.', 'Oats & loose nuts.', 3.60, 1, '400000004' FROM categories c WHERE c.code='postres'
UNION ALL SELECT UUID(), c.id, 'Helado de cáscaras', 'Peel ice cream', 'Cáscaras infusionadas.', 'Infused peels.', 4.50, 0, '400000005' FROM categories c WHERE c.code='postres'
UNION ALL SELECT UUID(), c.id, 'Peras al vino aprovechado', 'Leftover wine pears', 'Vino de servicio anterior.', 'Leftover service wine.', 4.80, 0, '400000006' FROM categories c WHERE c.code='postres';

-- Ejemplos de mapeo de alérgenos
INSERT INTO product_allergen (product_id, allergen_code, contains, may_contain)
SELECT p.id, 'gluten', 1, 0 FROM products p WHERE p.name_es IN ('Tostada de pan del día','Pudin de pan','Granola casera')
ON DUPLICATE KEY UPDATE contains=VALUES(contains), may_contain=VALUES(may_contain);

INSERT INTO product_allergen (product_id, allergen_code, contains, may_contain)
SELECT p.id, 'lactose', 1, 0 FROM products p WHERE p.name_es IN ('Tortilla de recortes','Frittata antidesperdicio','Helado de cáscaras','Brownie cacao sostenible')
ON DUPLICATE KEY UPDATE contains=VALUES(contains), may_contain=VALUES(may_contain);

INSERT INTO rescue_menus (uuid, name_es, name_en, description_es, description_en, drink_id, starter_id, main_id, dessert_id, price, is_vegan)
SELECT
  UUID(),
  'Menú Rescate 1',
  'Rescue Menu 1',
  'Menú completo de aprovechamiento.',
  'Full zero-waste menu.',
  (SELECT id FROM products WHERE name_es='Agua filtrada' LIMIT 1),
  (SELECT id FROM products WHERE name_es='Ensalada tallos & hojas' LIMIT 1),
  (SELECT id FROM products WHERE name_es='Pasta al pesto de hojas' LIMIT 1),
  (SELECT id FROM products WHERE name_es='Compota de fruta madura' LIMIT 1),
  15.90, 1;

INSERT INTO rescue_menus (uuid, name_es, name_en, description_es, description_en, drink_id, starter_id, main_id, dessert_id, price, is_vegan)
SELECT
  UUID(),
  'Menú Rescate 2',
  'Rescue Menu 2',
  'Menú del día con kombucha.',
  'Daily menu with kombucha.',
  (SELECT id FROM products WHERE name_es='Kombucha casera' LIMIT 1),
  (SELECT id FROM products WHERE name_es='Hummus de legumbre del día' LIMIT 1),
  (SELECT id FROM products WHERE name_es='Wok de tallos' LIMIT 1),
  (SELECT id FROM products WHERE name_es='Granola casera' LIMIT 1),
  16.50, 1;

INSERT INTO rescue_menus (uuid, name_es, name_en, description_es, description_en, drink_id, starter_id, main_id, dessert_id, price, is_vegan)
SELECT
  UUID(),
  'Menú Casero',
  'Homestyle Menu',
  'Menú tradicional del día.',
  'Traditional daily menu.',
  (SELECT id FROM products WHERE name_es='Limonada de temporada' LIMIT 1),
  (SELECT id FROM products WHERE name_es='Crema de verduras del día' LIMIT 1),
  (SELECT id FROM products WHERE name_es='Arroz de temporada' LIMIT 1),
  (SELECT id FROM products WHERE name_es='Pudin de pan' LIMIT 1),
  17.90, 0;

INSERT INTO rescue_menus (uuid, name_es, name_en, description_es, description_en, drink_id, starter_id, main_id, dessert_id, price, is_vegan)
SELECT
  UUID(),
  'Menú Vegano',
  'Vegan Menu',
  'Opciones 100% vegetales del día.',
  '100% plant-based options.',
  (SELECT id FROM products WHERE name_es='Infusión de pieles cítricas' LIMIT 1),
  (SELECT id FROM products WHERE name_es='Tostada de pan del día' LIMIT 1),
  (SELECT id FROM products WHERE name_es='Curry de recortes' LIMIT 1),
  (SELECT id FROM products WHERE name_es='Compota de fruta madura' LIMIT 1),
  16.90, 1;

INSERT INTO rescue_menus (uuid, name_es, name_en, description_es, description_en, drink_id, starter_id, main_id, dessert_id, price, is_vegan)
SELECT
  UUID(),
  'Menú Express',
  'Express Menu',
  'Menú rápido y completo.',
  'Quick and complete menu.',
  (SELECT id FROM products WHERE name_es='Agua con hierbas del huerto' LIMIT 1),
  (SELECT id FROM products WHERE name_es='Ensalada tallos & hojas' LIMIT 1),
  (SELECT id FROM products WHERE name_es='Hamburguesa veggie del día' LIMIT 1),
  (SELECT id FROM products WHERE name_es='Granola casera' LIMIT 1),
  16.20, 1;

INSERT INTO rescue_menus (uuid, name_es, name_en, description_es, description_en, drink_id, starter_id, main_id, dessert_id, price, is_vegan)
SELECT
  UUID(),
  'Menú Antidesperdicio',
  'Anti-waste Menu',
  'Selección del chef contra el desperdicio.',
  'Chef''s anti-waste selection.',
  (SELECT id FROM products WHERE name_es='Té frío reutilizado' LIMIT 1),
  (SELECT id FROM products WHERE name_es='Tortilla de recortes' LIMIT 1),
  (SELECT id FROM products WHERE name_es='Frittata antidesperdicio' LIMIT 1),
  (SELECT id FROM products WHERE name_es='Peras al vino aprovechado' LIMIT 1),
  18.50, 0;

-- Regla de fidelidad (cada 10 compras = 1 menú gratis)
INSERT INTO loyalty_rules (uuid, code, every_n_purchases, reward_type)
VALUES (UUID(), 'every_10_purchases_free_menu', 10, 'free_menu')
ON DUPLICATE KEY UPDATE every_n_purchases=VALUES(every_n_purchases);