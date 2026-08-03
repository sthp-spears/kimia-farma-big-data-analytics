CREATE OR REPLACE TABLE
`kimia-farma-pbi-504303.kimia_farma_dataset.kf_analysis`
AS

WITH inventory AS (
SELECT
    branch_id,
    product_id,
    MAX(opname_stock) AS opname_stock
FROM `kimia-farma-pbi-504303.kimia_farma_dataset.kf_inventory`
GROUP BY
    branch_id,
    product_id
)

SELECT

-- Transaction
ft.transaction_id,
ft.date,

-- Branch
ft.branch_id,
kc.branch_name,
kc.kota,
kc.provinsi,
kc.rating AS rating_cabang,

-- Customer
ft.customer_name,

-- Product
ft.product_id,
p.product_name,

-- Price
ft.price AS actual_price,
ft.discount_percentage,

CASE
    WHEN ft.price <= 50000 THEN 0.10
    WHEN ft.price <= 100000 THEN 0.15
    WHEN ft.price <= 300000 THEN 0.20
    WHEN ft.price <= 500000 THEN 0.25
    ELSE 0.30
END AS persentase_gross_laba,

ROUND(
    ft.price * (1 - ft.discount_percentage),
    2
) AS nett_sales,

ROUND(
    (ft.price * (1 - ft.discount_percentage))
    *
    (
        CASE
            WHEN ft.price <= 50000 THEN 0.10
            WHEN ft.price <= 100000 THEN 0.15
            WHEN ft.price <= 300000 THEN 0.20
            WHEN ft.price <= 500000 THEN 0.25
            ELSE 0.30
        END
    ),
    2
) AS nett_profit,

ft.rating AS rating_transaksi,

-- Inventory
inv.opname_stock

FROM
`kimia-farma-pbi-504303.kimia_farma_dataset.kf_final_transaction` ft

LEFT JOIN
`kimia-farma-pbi-504303.kimia_farma_dataset.kf_kantor_cabang` kc
ON ft.branch_id = kc.branch_id

LEFT JOIN
`kimia-farma-pbi-504303.kimia_farma_dataset.kf_product` p
ON ft.product_id = p.product_id

LEFT JOIN
inventory inv
ON ft.branch_id = inv.branch_id
AND ft.product_id = inv.product_id;