# Lab 05 — Composite Index Order
A composite index is useful when a query commonly uses the same columns together.
Column order inside a composite index matters.

## Goal

composite index

We have indexes:
IX_OPT_ORDERS_CITY_STATUS   (city, status)
IX_OPT_ORDERS_STATUS_CITY   (status, city)

test different predicates and see which index Oracle chooses.