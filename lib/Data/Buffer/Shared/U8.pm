package Data::Buffer::Shared::U8;
use strict;
use warnings;
use Data::Buffer::Shared;
our $VERSION = '0.01';

sub import {
    $^H{"Data::Buffer::Shared::U8/buf_u8_get"} = 1;
    $^H{"Data::Buffer::Shared::U8/buf_u8_set"} = 1;
    $^H{"Data::Buffer::Shared::U8/buf_u8_slice"} = 1;
    $^H{"Data::Buffer::Shared::U8/buf_u8_fill"} = 1;
    $^H{"Data::Buffer::Shared::U8/buf_u8_capacity"} = 1;
    $^H{"Data::Buffer::Shared::U8/buf_u8_mmap_size"} = 1;
    $^H{"Data::Buffer::Shared::U8/buf_u8_elem_size"} = 1;
    $^H{"Data::Buffer::Shared::U8/buf_u8_lock_wr"} = 1;
    $^H{"Data::Buffer::Shared::U8/buf_u8_unlock_wr"} = 1;
    $^H{"Data::Buffer::Shared::U8/buf_u8_lock_rd"} = 1;
    $^H{"Data::Buffer::Shared::U8/buf_u8_unlock_rd"} = 1;
    $^H{"Data::Buffer::Shared::U8/buf_u8_incr"} = 1;
    $^H{"Data::Buffer::Shared::U8/buf_u8_decr"} = 1;
    $^H{"Data::Buffer::Shared::U8/buf_u8_add"} = 1;
    $^H{"Data::Buffer::Shared::U8/buf_u8_cas"} = 1;
}

1;
