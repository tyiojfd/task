package com.poster.model;

import java.util.List;

/**
 * Generic pagination wrapper.
 *
 * @param <T> item type
 */
public class PageInfo<T> {

    private final List<T> items;
    private final int page;
    private final int pageSize;
    private final long totalItems;
    private final int totalPages;

    public PageInfo(List<T> items, long totalItems, int page, int pageSize) {
        this.items = items;
        this.totalItems = totalItems;
        this.page = Math.max(1, page);
        this.pageSize = Math.max(1, pageSize);
        this.totalPages = (int) Math.max(1, Math.ceil((double) totalItems / this.pageSize));
    }

    public List<T> getItems()       { return items; }
    public int     getPage()        { return page; }
    public int     getPageSize()    { return pageSize; }
    public long    getTotalItems()  { return totalItems; }
    public int     getTotalPages()  { return totalPages; }
    public boolean getHasPrev()     { return page > 1; }
    public boolean getHasNext()     { return page < totalPages; }

    /** Zero-based offset for SQL queries. */
    public int getOffset()          { return (page - 1) * pageSize; }
}
