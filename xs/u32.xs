MODULE = Data::Buffer::Shared    PACKAGE = Data::Buffer::Shared::U32
PROTOTYPES: DISABLE

SV*
new(char* class, char* path, UV capacity)
    CODE:
        char errbuf[BUF_ERR_BUFLEN];
        BufHandle* buf = buf_u32_create(path, (uint64_t)capacity, errbuf);
        if (!buf) croak("Data::Buffer::Shared::U32: %s", errbuf[0] ? errbuf : "unknown error");
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
        EXTRACT_BUF("Data::Buffer::Shared::U32", self_sv);
        uint32_t val;
        if (!buf_u32_get(h, (uint64_t)idx, &val)) XSRETURN_UNDEF;
        RETVAL = newSVuv(val);
    OUTPUT:
        RETVAL

bool
set(SV* self_sv, UV idx, UV val)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U32", self_sv);
        RETVAL = buf_u32_set(h, (uint64_t)idx, (uint32_t)val);
    OUTPUT:
        RETVAL

void
slice(SV* self_sv, UV from, UV count)
    PPCODE:
        EXTRACT_BUF("Data::Buffer::Shared::U32", self_sv);
        if (count == 0) XSRETURN_EMPTY;
        uint32_t *tmp;
        Newx(tmp, count, uint32_t);
        SAVEFREEPV(tmp);
        if (!buf_u32_get_slice(h, (uint64_t)from, (uint64_t)count, tmp))
            croak("Data::Buffer::Shared::U32: slice out of bounds");
        EXTEND(SP, count);
        for (UV i = 0; i < count; i++)
            mPUSHu(tmp[i]);

bool
set_slice(SV* self_sv, UV from, ...)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U32", self_sv);
        UV count = items - 2;
        if (count == 0) XSRETURN(1);
        uint32_t *tmp;
        Newx(tmp, count, uint32_t);
        SAVEFREEPV(tmp);
        for (UV i = 0; i < count; i++)
            tmp[i] = (uint32_t)SvUV(ST(i + 2));
        RETVAL = buf_u32_set_slice(h, (uint64_t)from, (uint64_t)count, tmp);
    OUTPUT:
        RETVAL

void
fill(SV* self_sv, UV val)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U32", self_sv);
        buf_u32_fill(h, (uint32_t)val);

SV*
incr(SV* self_sv, UV idx)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U32", self_sv);
        if (idx >= h->hdr->capacity) croak("Data::Buffer::Shared::U32: index out of bounds");
        RETVAL = newSVuv(buf_u32_incr(h, (uint64_t)idx));
    OUTPUT:
        RETVAL

SV*
decr(SV* self_sv, UV idx)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U32", self_sv);
        if (idx >= h->hdr->capacity) croak("Data::Buffer::Shared::U32: index out of bounds");
        RETVAL = newSVuv(buf_u32_decr(h, (uint64_t)idx));
    OUTPUT:
        RETVAL

SV*
add(SV* self_sv, UV idx, UV delta)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U32", self_sv);
        if (idx >= h->hdr->capacity) croak("Data::Buffer::Shared::U32: index out of bounds");
        RETVAL = newSVuv(buf_u32_add(h, (uint64_t)idx, (uint32_t)delta));
    OUTPUT:
        RETVAL

bool
cas(SV* self_sv, UV idx, UV expected, UV desired)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U32", self_sv);
        RETVAL = buf_u32_cas(h, (uint64_t)idx, (uint32_t)expected, (uint32_t)desired);
    OUTPUT:
        RETVAL

UV
capacity(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U32", self_sv);
        RETVAL = (UV)buf_u32_capacity(h);
    OUTPUT:
        RETVAL

UV
mmap_size(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U32", self_sv);
        RETVAL = (UV)buf_u32_mmap_size(h);
    OUTPUT:
        RETVAL

UV
elem_size(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U32", self_sv);
        RETVAL = (UV)buf_u32_elem_size(h);
    OUTPUT:
        RETVAL

SV*
path(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U32", self_sv);
        if (h->path) RETVAL = newSVpv(h->path, 0); else XSRETURN_UNDEF;
    OUTPUT:
        RETVAL

void
lock_wr(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U32", self_sv);
        buf_u32_lock_wr(h);

void
unlock_wr(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U32", self_sv);
        buf_u32_unlock_wr(h);

void
lock_rd(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U32", self_sv);
        buf_u32_lock_rd(h);

void
unlock_rd(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U32", self_sv);
        buf_u32_unlock_rd(h);

void
unlink(SV* self_or_class, ...)
    CODE:
        const char *p;
        if (SvROK(self_or_class)) {
            BufHandle* h = INT2PTR(BufHandle*, SvIV(SvRV(self_or_class)));
            if (h) p = h->path;
            else croak("Data::Buffer::Shared::U32: destroyed object");
        } else {
            if (items < 2) croak("Usage: Data::Buffer::Shared::U32->unlink($path)");
            p = SvPV_nolen(ST(1));
        }
        unlink(p);

UV
ptr(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U32", self_sv);
        RETVAL = PTR2UV(buf_u32_ptr(h));
    OUTPUT:
        RETVAL

UV
ptr_at(SV* self_sv, UV idx)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U32", self_sv);
        void *p = buf_u32_ptr_at(h, (uint64_t)idx);
        if (!p) croak("Data::Buffer::Shared::U32: index out of bounds");
        RETVAL = PTR2UV(p);
    OUTPUT:
        RETVAL

SV*
new_anon(char* class, UV capacity)
    CODE:
        char errbuf[BUF_ERR_BUFLEN];
        BufHandle* buf = buf_u32_create_anon((uint64_t)capacity, errbuf);
        if (!buf) croak("Data::Buffer::Shared::U32: %s", errbuf[0] ? errbuf : "unknown error");
        RETVAL = sv_setref_pv(newSV(0), class, (void*)buf);
    OUTPUT:
        RETVAL

void
clear(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U32", self_sv);
        buf_u32_clear(h);

SV*
get_raw(SV* self_sv, UV byte_off, UV nbytes)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U32", self_sv);
        RETVAL = newSV(nbytes);
        SvPOK_on(RETVAL);
        SvCUR_set(RETVAL, nbytes);
        if (!buf_u32_get_raw(h, (uint64_t)byte_off, (uint64_t)nbytes, SvPVX(RETVAL))) {
            SvREFCNT_dec(RETVAL);
            croak("Data::Buffer::Shared::U32: get_raw out of bounds");
        }
    OUTPUT:
        RETVAL

bool
set_raw(SV* self_sv, UV byte_off, SV* data_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U32", self_sv);
        STRLEN dlen;
        const char *dptr = SvPV(data_sv, dlen);
        RETVAL = buf_u32_set_raw(h, (uint64_t)byte_off, (uint64_t)dlen, dptr);
    OUTPUT:
        RETVAL

SV*
cmpxchg(SV* self_sv, UV idx, UV expected, UV desired)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U32", self_sv);
        if (idx >= h->hdr->capacity) croak("Data::Buffer::Shared::U32: index out of bounds");
        RETVAL = newSVuv(buf_u32_cmpxchg(h, (uint64_t)idx, (uint32_t)expected, (uint32_t)desired));
    OUTPUT:
        RETVAL

SV*
atomic_and(SV* self_sv, UV idx, UV mask)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U32", self_sv);
        if (idx >= h->hdr->capacity) croak("Data::Buffer::Shared::U32: index out of bounds");
        RETVAL = newSVuv(buf_u32_atomic_and(h, (uint64_t)idx, (uint32_t)mask));
    OUTPUT:
        RETVAL

SV*
atomic_or(SV* self_sv, UV idx, UV mask)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U32", self_sv);
        if (idx >= h->hdr->capacity) croak("Data::Buffer::Shared::U32: index out of bounds");
        RETVAL = newSVuv(buf_u32_atomic_or(h, (uint64_t)idx, (uint32_t)mask));
    OUTPUT:
        RETVAL

SV*
atomic_xor(SV* self_sv, UV idx, UV mask)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::U32", self_sv);
        if (idx >= h->hdr->capacity) croak("Data::Buffer::Shared::U32: index out of bounds");
        RETVAL = newSVuv(buf_u32_atomic_xor(h, (uint64_t)idx, (uint32_t)mask));
    OUTPUT:
        RETVAL
