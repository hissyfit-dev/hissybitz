//! Making a song and dance about hissybitz.

const std = @import("std");
const debug = std.debug;
const io = std.io;

const hissylogz = @import("hissylogz");
const LoggerPool = hissylogz.LoggerPool;
const hissybitz = @import("hissybitz.zig");
const ulid = hissybitz.ulid;

const errors = hissybitz.errors;

pub fn main() !void {
    std.debug.print("hissybitz - song and dance\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var logger_pool = try hissylogz.loggerPool(allocator, .{
        .filter_level = .fine,
        .log_format = .text,
        .writer = @constCast(&std.io.getStdOut().writer()),
    });
    defer logger_pool.deinit();
    var logger = logger_pool.logger("hissybitz");

    const num = 1_000_000;
    var generator = ulid.generator();

    var ulids = try allocator.alloc(ulid.Ulid, num);
    defer allocator.free(ulids);
    {
        var timer = try std.time.Timer.start();
        for (0..num) |i| {
            ulids[i] = try generator.next();
        }
        const dur = timer.read();
        logger.info()
            .ctx("ulids")
            .fmt("ids/s", "{d:.2}", .{@as(f64, @floatFromInt(num)) * std.time.ns_per_s / @as(f64, @floatFromInt(dur))})
            .log();
    }

    var strs = try allocator.alloc([ulid.text_length]u8, num);
    defer allocator.free(strs);
    {
        var timer = try std.time.Timer.start();
        timer.reset();
        for (0..num) |i| {
            ulids[i].encodeBuf(&strs[i]) catch unreachable;
        }
        const dur = timer.read();
        logger.info()
            .ctx("ulid->str")
            .fmt("encodes/s", "{d:.2}", .{@as(f64, @floatFromInt(num)) * std.time.ns_per_s / @as(f64, @floatFromInt(dur))})
            .log();
    }

    var bytes = try allocator.alloc([ulid.binary_length]u8, num);
    defer allocator.free(bytes);
    {
        var timer = try std.time.Timer.start();
        timer.reset();
        for (0..num) |i| {
            bytes[i] = ulids[i].bytes();
        }
        const dur = timer.read();
        logger.info()
            .ctx("ulid->bytes")
            .fmt("binencodes/s", "{d:.2}", .{@as(f64, @floatFromInt(num)) * std.time.ns_per_s / @as(f64, @floatFromInt(dur))})
            .log();
    }

    {
        var timer = try std.time.Timer.start();
        timer.reset();
        for (0..num) |i| {
            ulids[i] = try ulid.decode(&strs[i]);
        }
        const dur = timer.read();
        logger.info()
            .ctx("str->ulid")
            .fmt("decodes/s", "{d:.2}", .{@as(f64, @floatFromInt(num)) * std.time.ns_per_s / @as(f64, @floatFromInt(dur))})
            .log();
    }

    {
        var timer = try std.time.Timer.start();
        timer.reset();
        for (0..num) |i| {
            ulids[i] = try ulid.fromBytes(&bytes[i]);
        }
        const dur = timer.read();
        logger.info()
            .ctx("bytes->ulid")
            .fmt("bindecodes/s", "{d:.2}", .{@as(f64, @floatFromInt(num)) * std.time.ns_per_s / @as(f64, @floatFromInt(dur))})
            .log();
    }
}

// ---
// hissybitz.
//
// Copyright 2024 Kevin Poalses.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
