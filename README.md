#Asynchronous FIFO

The asynchronous FIFO architecture enables reliable data transfer between two independent clock domains. The write side operates on the write clock (wr_clk), while the read side operates on the read clock (rd_clk).

Data written into the FIFO memory is addressed using a write pointer, and data read from the FIFO uses a read pointer. To safely transfer pointer information across clock domains, the pointers are converted to Gray code, ensuring that only one bit changes at a time and minimizing metastability issues.

The FIFO memory block stores the data, while the control logic generates full and empty status flags based on the relative positions of the write and read pointers.

This architecture ensures safe clock domain crossing (CDC) and maintains correct First-In-First-Out (FIFO) data ordering.
