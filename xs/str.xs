MODULE = Data::Buffer::Shared    PACKAGE = Data::Buffer::Shared::Str
PROTOTYPES: DISABLE

SV*
new(char* class, char* path, UV capacity, UV str_len)
    CODE:
        char errbuf[BUF_ERR_BUFLEN];
        BufHandle* buf = buf_str_create(path, (uint64_t)capacity, (uint32_t)str_len, errbuf);
        if (!buf) croak("Data::Buffer::Shared::Str: %s", errbuf[0] ? errbuf : "unknown error");
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
        EXTRACT_BUF("Data::Buffer::Shared::Str", self_sv);
        uint32_t esz = h->hdr->elem_size;
        char *tmp;
        Newx(tmp, esz + 1, char);
        SAVEFREEPV(tmp);
        uint32_t out_len;
        if (!buf_str_get(h, (uint64_t)idx, tmp, &out_len)) XSRETURN_UNDEF;
        RETVAL = newSVpvn(tmp, out_len);
    OUTPUT:
        RETVAL

bool
set(SV* self_sv, UV idx, SV* val_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::Str", self_sv);
        STRLEN vlen;
        const char *vstr = SvPV(val_sv, vlen);
        RETVAL = buf_str_set(h, (uint64_t)idx, vstr, (uint32_t)vlen);
    OUTPUT:
        RETVAL

void
slice(SV* self_sv, UV from, UV count)
    PPCODE:
        EXTRACT_BUF("Data::Buffer::Shared::Str", self_sv);
        if (count == 0) XSRETURN_EMPTY;
        uint32_t esz = h->hdr->elem_size;
        char *tmp;
        Newx(tmp, count * esz, char);
        SAVEFREEPV(tmp);
        if (!buf_str_get_slice(h, (uint64_t)from, (uint64_t)count, tmp))
            croak("Data::Buffer::Shared::Str: slice out of bounds");
        EXTEND(SP, count);
        for (UV i = 0; i < count; i++) {
            char *elem = tmp + i * esz;
            uint32_t len = esz;
            while (len > 0 && elem[len - 1] == '\0') len--;
            mXPUSHp(elem, len);
        }

bool
set_slice(SV* self_sv, UV from, ...)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::Str", self_sv);
        UV count = items - 2;
        if (count == 0) XSRETURN(1);
        uint32_t esz = h->hdr->elem_size;
        char *tmp;
        Newxz(tmp, count * esz, char);
        SAVEFREEPV(tmp);
        for (UV i = 0; i < count; i++) {
            STRLEN vlen;
            const char *vstr = SvPV(ST(i + 2), vlen);
            uint32_t copy_len = (uint32_t)(vlen < esz ? vlen : esz);
            memcpy(tmp + i * esz, vstr, copy_len);
        }
        RETVAL = buf_str_set_slice(h, (uint64_t)from, (uint64_t)count, tmp);
    OUTPUT:
        RETVAL

void
fill(SV* self_sv, SV* val_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::Str", self_sv);
        STRLEN vlen;
        const char *vstr = SvPV(val_sv, vlen);
        buf_str_fill(h, vstr, (uint32_t)vlen);

UV
capacity(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::Str", self_sv);
        RETVAL = (UV)buf_str_capacity(h);
    OUTPUT:
        RETVAL

UV
mmap_size(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::Str", self_sv);
        RETVAL = (UV)buf_str_mmap_size(h);
    OUTPUT:
        RETVAL

UV
elem_size(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::Str", self_sv);
        RETVAL = (UV)buf_str_elem_size(h);
    OUTPUT:
        RETVAL

SV*
path(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::Str", self_sv);
        RETVAL = newSVpv(h->path, 0);
    OUTPUT:
        RETVAL

void
lock_wr(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::Str", self_sv);
        buf_str_lock_wr(h);

void
unlock_wr(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::Str", self_sv);
        buf_str_unlock_wr(h);

void
lock_rd(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::Str", self_sv);
        buf_str_lock_rd(h);

void
unlock_rd(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::Str", self_sv);
        buf_str_unlock_rd(h);

void
unlink(SV* self_or_class, ...)
    CODE:
        const char *p;
        if (SvROK(self_or_class)) {
            BufHandle* h = INT2PTR(BufHandle*, SvIV(SvRV(self_or_class)));
            if (h) p = h->path;
            else croak("Data::Buffer::Shared::Str: destroyed object");
        } else {
            if (items < 2) croak("Usage: Data::Buffer::Shared::Str->unlink($path)");
            p = SvPV_nolen(ST(1));
        }
        unlink(p);

UV
ptr(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::Str", self_sv);
        RETVAL = PTR2UV(buf_str_ptr(h));
    OUTPUT:
        RETVAL

UV
ptr_at(SV* self_sv, UV idx)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::Str", self_sv);
        void *p = buf_str_ptr_at(h, (uint64_t)idx);
        if (!p) croak("Data::Buffer::Shared::Str: index out of bounds");
        RETVAL = PTR2UV(p);
    OUTPUT:
        RETVAL
