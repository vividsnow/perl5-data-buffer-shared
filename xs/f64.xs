MODULE = Data::Buffer::Shared    PACKAGE = Data::Buffer::Shared::F64
PROTOTYPES: DISABLE

SV*
new(char* class, char* path, UV capacity)
    CODE:
        char errbuf[BUF_ERR_BUFLEN];
        BufHandle* buf = buf_f64_create(path, (uint64_t)capacity, errbuf);
        if (!buf) croak("Data::Buffer::Shared::F64: %s", errbuf[0] ? errbuf : "unknown error");
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
        EXTRACT_BUF("Data::Buffer::Shared::F64", self_sv);
        double val;
        if (!buf_f64_get(h, (uint64_t)idx, &val)) XSRETURN_UNDEF;
        RETVAL = newSVnv(val);
    OUTPUT:
        RETVAL

bool
set(SV* self_sv, UV idx, NV val)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::F64", self_sv);
        RETVAL = buf_f64_set(h, (uint64_t)idx, (double)val);
    OUTPUT:
        RETVAL

void
slice(SV* self_sv, UV from, UV count)
    PPCODE:
        EXTRACT_BUF("Data::Buffer::Shared::F64", self_sv);
        if (count == 0) XSRETURN_EMPTY;
        double *tmp;
        Newx(tmp, count, double);
        SAVEFREEPV(tmp);
        if (!buf_f64_get_slice(h, (uint64_t)from, (uint64_t)count, tmp))
            croak("Data::Buffer::Shared::F64: slice out of bounds");
        EXTEND(SP, count);
        for (UV i = 0; i < count; i++)
            mPUSHn(tmp[i]);

bool
set_slice(SV* self_sv, UV from, ...)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::F64", self_sv);
        UV count = items - 2;
        if (count == 0) XSRETURN(1);
        double *tmp;
        Newx(tmp, count, double);
        SAVEFREEPV(tmp);
        for (UV i = 0; i < count; i++)
            tmp[i] = (double)SvNV(ST(i + 2));
        RETVAL = buf_f64_set_slice(h, (uint64_t)from, (uint64_t)count, tmp);
    OUTPUT:
        RETVAL

void
fill(SV* self_sv, NV val)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::F64", self_sv);
        buf_f64_fill(h, (double)val);

UV
capacity(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::F64", self_sv);
        RETVAL = (UV)buf_f64_capacity(h);
    OUTPUT:
        RETVAL

UV
mmap_size(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::F64", self_sv);
        RETVAL = (UV)buf_f64_mmap_size(h);
    OUTPUT:
        RETVAL

UV
elem_size(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::F64", self_sv);
        RETVAL = (UV)buf_f64_elem_size(h);
    OUTPUT:
        RETVAL

SV*
path(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::F64", self_sv);
        if (h->path) RETVAL = newSVpv(h->path, 0); else XSRETURN_UNDEF;
    OUTPUT:
        RETVAL

void
lock_wr(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::F64", self_sv);
        buf_f64_lock_wr(h);

void
unlock_wr(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::F64", self_sv);
        buf_f64_unlock_wr(h);

void
lock_rd(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::F64", self_sv);
        buf_f64_lock_rd(h);

void
unlock_rd(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::F64", self_sv);
        buf_f64_unlock_rd(h);

void
unlink(SV* self_or_class, ...)
    CODE:
        const char *p;
        if (SvROK(self_or_class)) {
            BufHandle* h = INT2PTR(BufHandle*, SvIV(SvRV(self_or_class)));
            if (h) p = h->path;
            else croak("Data::Buffer::Shared::F64: destroyed object");
        } else {
            if (items < 2) croak("Usage: Data::Buffer::Shared::F64->unlink($path)");
            p = SvPV_nolen(ST(1));
        }
        unlink(p);

UV
ptr(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::F64", self_sv);
        RETVAL = PTR2UV(buf_f64_ptr(h));
    OUTPUT:
        RETVAL

UV
ptr_at(SV* self_sv, UV idx)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::F64", self_sv);
        void *p = buf_f64_ptr_at(h, (uint64_t)idx);
        if (!p) croak("Data::Buffer::Shared::F64: index out of bounds");
        RETVAL = PTR2UV(p);
    OUTPUT:
        RETVAL

SV*
new_anon(char* class, UV capacity)
    CODE:
        char errbuf[BUF_ERR_BUFLEN];
        BufHandle* buf = buf_f64_create_anon((uint64_t)capacity, errbuf);
        if (!buf) croak("Data::Buffer::Shared::F64: %s", errbuf[0] ? errbuf : "unknown error");
        RETVAL = sv_setref_pv(newSV(0), class, (void*)buf);
    OUTPUT:
        RETVAL

void
clear(SV* self_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::F64", self_sv);
        buf_f64_clear(h);

SV*
get_raw(SV* self_sv, UV byte_off, UV nbytes)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::F64", self_sv);
        RETVAL = newSV(nbytes);
        SvPOK_on(RETVAL);
        SvCUR_set(RETVAL, nbytes);
        if (!buf_f64_get_raw(h, (uint64_t)byte_off, (uint64_t)nbytes, SvPVX(RETVAL))) {
            SvREFCNT_dec(RETVAL);
            croak("Data::Buffer::Shared::F64: get_raw out of bounds");
        }
    OUTPUT:
        RETVAL

bool
set_raw(SV* self_sv, UV byte_off, SV* data_sv)
    CODE:
        EXTRACT_BUF("Data::Buffer::Shared::F64", self_sv);
        STRLEN dlen;
        const char *dptr = SvPV(data_sv, dlen);
        RETVAL = buf_f64_set_raw(h, (uint64_t)byte_off, (uint64_t)dlen, dptr);
    OUTPUT:
        RETVAL
