package Data::Buffer::Shared::I8;
use strict;
use warnings;
use Data::Buffer::Shared;
our $VERSION = '0.01';

sub import {
    $^H{"Data::Buffer::Shared::I8/buf_i8_get"} = 1;
    $^H{"Data::Buffer::Shared::I8/buf_i8_set"} = 1;
    $^H{"Data::Buffer::Shared::I8/buf_i8_slice"} = 1;
    $^H{"Data::Buffer::Shared::I8/buf_i8_fill"} = 1;
    $^H{"Data::Buffer::Shared::I8/buf_i8_capacity"} = 1;
    $^H{"Data::Buffer::Shared::I8/buf_i8_mmap_size"} = 1;
    $^H{"Data::Buffer::Shared::I8/buf_i8_elem_size"} = 1;
    $^H{"Data::Buffer::Shared::I8/buf_i8_lock_wr"} = 1;
    $^H{"Data::Buffer::Shared::I8/buf_i8_unlock_wr"} = 1;
    $^H{"Data::Buffer::Shared::I8/buf_i8_lock_rd"} = 1;
    $^H{"Data::Buffer::Shared::I8/buf_i8_unlock_rd"} = 1;
    $^H{"Data::Buffer::Shared::I8/buf_i8_incr"} = 1;
    $^H{"Data::Buffer::Shared::I8/buf_i8_decr"} = 1;
    $^H{"Data::Buffer::Shared::I8/buf_i8_add"} = 1;
    $^H{"Data::Buffer::Shared::I8/buf_i8_cas"} = 1;
}

1;
