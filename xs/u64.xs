MODULE = Data::Buffer::Shared    PACKAGE = Data::Buffer::Shared::U64
PROTOTYPES: DISABLE

SV*
new(char* class, char* path, UV capacity)
    CODE:
        char errbuf[BUF_ERR_BUFLEN];
        BufHandle* buf = buf_u64_create(path, (uint64_t)capacity, errbuf);
        if (!buf) croak("Data::Buffer::Shared::U64: %s", errbuf[0] ? errbuf : "unknown error");
        RETVAL = sv_setref_pv(newSV(0), class, (void*)buf);
    OUTPUT:
        RETVAL

void
DESTROY(SV* self_sv)
    CODE:
        if (!SvROK(self_sv)) return;
        BufHandle* h = INT2PTR(BufHandle*, SvIV(SvRV(self_sv)));
        if (!h) return;
        buf_close_map(h);
        sv_setiv(SvRV(self_sv), 0);

SV*
get(SV* self_sv, UV idx)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U64", self_sv);
        uint64_t val;
        if (!buf_u64_get(h, (uint64_t)idx, &val)) XSRETURN_UNDEF;
        RETVAL = newSVuv(val);
    OUTPUT:
        RETVAL

bool
set(SV* self_sv, UV idx, UV val)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U64", self_sv);
        RETVAL = buf_u64_set(h, (uint64_t)idx, (uint64_t)val);
    OUTPUT:
        RETVAL

void
slice(SV* self_sv, UV from, UV count)
    PPCODE:
        EXTRACT_BUF("Data::Buffer::Shared::U64", self_sv);
        if (count == 0) XSRETURN_EMPTY;
        uint64_t *tmp;
        Newx(tmp, count, uint64_t);
        SAVEFREEPV(tmp);
        if (!buf_u64_get_slice(h, (uint64_t)from, (uint64_t)count, tmp))
            croak("Data::Buffer::Shared::U64: slice out of bounds");
        EXTEND(SP, count);
        for (UV i = 0; i < count; i++)
            mPUSHu(tmp[i]);

bool
set_slice(SV* self_sv, UV from, ...)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U64", self_sv);
        UV count = items - 2;
        if (count == 0) XSRETURN(1);
        uint64_t *tmp;
        Newx(tmp, count, uint64_t);
        SAVEFREEPV(tmp);
        for (UV i = 0; i < count; i++)
            tmp[i] = (uint64_t)SvUV(ST(i + 2));
        RETVAL = buf_u64_set_slice(h, (uint64_t)from, (uint64_t)count, tmp);
    OUTPUT:
        RETVAL

void
fill(SV* self_sv, UV val)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U64", self_sv);
        buf_u64_fill(h, (uint64_t)val);

SV*
incr(SV* self_sv, UV idx)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U64", self_sv);
        if (idx >= h->hdr->capacity) croak("Data::Buffer::Shared::U64: index out of bounds");
        RETVAL = newSVuv(buf_u64_incr(h, (uint64_t)idx));
    OUTPUT:
        RETVAL

SV*
decr(SV* self_sv, UV idx)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U64", self_sv);
        if (idx >= h->hdr->capacity) croak("Data::Buffer::Shared::U64: index out of bounds");
        RETVAL = newSVuv(buf_u64_decr(h, (uint64_t)idx));
    OUTPUT:
        RETVAL

SV*
add(SV* self_sv, UV idx, UV delta)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U64", self_sv);
        if (idx >= h->hdr->capacity) croak("Data::Buffer::Shared::U64: index out of bounds");
        RETVAL = newSVuv(buf_u64_add(h, (uint64_t)idx, (uint64_t)delta));
    OUTPUT:
        RETVAL

bool
cas(SV* self_sv, UV idx, UV expected, UV desired)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U64", self_sv);
        RETVAL = buf_u64_cas(h, (uint64_t)idx, (uint64_t)expected, (uint64_t)desired);
    OUTPUT:
        RETVAL

UV
capacity(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U64", self_sv);
        RETVAL = (UV)buf_u64_capacity(h);
    OUTPUT:
        RETVAL

UV
mmap_size(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U64", self_sv);
        RETVAL = (UV)buf_u64_mmap_size(h);
    OUTPUT:
        RETVAL

UV
elem_size(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U64", self_sv);
        RETVAL = (UV)buf_u64_elem_size(h);
    OUTPUT:
        RETVAL

SV*
path(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U64", self_sv);
        RETVAL = newSVpv(h->path, 0);
    OUTPUT:
        RETVAL

void
lock_wr(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U64", self_sv);
        buf_u64_lock_wr(h);

void
unlock_wr(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U64", self_sv);
        buf_u64_unlock_wr(h);

void
lock_rd(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U64", self_sv);
        buf_u64_lock_rd(h);

void
unlock_rd(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U64", self_sv);
        buf_u64_unlock_rd(h);

void
unlink(SV* self_or_class, ...)
    CODE:
        const char *p;
        if (SvROK(self_or_class)) {
            BufHandle* h = INT2PTR(BufHandle*, SvIV(SvRV(self_or_class)));
            if (h) p = h->path;
            else croak("Data::Buffer::Shared::U64: destroyed object");
        } else {
            if (items < 2) croak("Usage: Data::Buffer::Shared::U64->unlink($path)");
            p = SvPV_nolen(ST(1));
        }
        unlink(p);
