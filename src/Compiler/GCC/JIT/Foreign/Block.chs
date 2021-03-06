{-# LANGUAGE ForeignFunctionInterface #-}
module Compiler.GCC.JIT.Foreign.Block where

#include <libgccjit.h>
{# context lib = "libgccjit" #}

{#import Compiler.GCC.JIT.Foreign.Types#}
import Compiler.GCC.JIT.Foreign.Utilities

import Foreign.C.Types
import Foreign.Ptr
import Foreign.Marshal.Array

import Data.ByteString (ByteString, useAsCString)
import Data.Maybe (isJust, fromJust)

-- * Block functions
-- | gcc_jit_block_add_eval
blockAddEval :: JITBlock -> Maybe JITLocation -> JITRValue -> IO ()
blockAddEval b l = {#call unsafe gcc_jit_block_add_eval#} b (fromMaybeLocation l)

-- | gcc_jit_block_add_assignment
blockAddAssignment :: JITBlock -> Maybe JITLocation -> JITLValue -> JITRValue -> IO ()
blockAddAssignment b l lv rv = {#call unsafe gcc_jit_block_add_assignment#} b (fromMaybeLocation l) lv rv

-- | gcc_jit_block_add_assignment_op
blockAddAssignmentOp :: JITBlock -> Maybe JITLocation -> JITLValue -> JITBinaryOp -> JITRValue -> IO ()
blockAddAssignmentOp b l lv op = {#call unsafe gcc_jit_block_add_assignment_op#} b (fromMaybeLocation l) lv (enumToCInt op)

-- |  gcc_jit_block_add_comment
blockAddComment :: JITBlock -> Maybe JITLocation -> ByteString -> IO ()
blockAddComment b l c = useAsCString c $ {#call unsafe gcc_jit_block_add_comment#} b (fromMaybeLocation l)

-- * Block End With Functions
-- | gcc_jit_block_end_with_conditional
blockEndWithConditional :: JITBlock -> Maybe JITLocation -> JITRValue -> JITBlock -> JITBlock -> IO ()
blockEndWithConditional b l = {#call unsafe gcc_jit_block_end_with_conditional#} b (fromMaybeLocation l)

-- | gcc_jit_block_end_with_jump
blockEndWithJump :: JITBlock -> Maybe JITLocation -> JITBlock -> IO ()
blockEndWithJump b l = {#call unsafe gcc_jit_block_end_with_jump#} b (fromMaybeLocation l)

-- | gcc_jit_block_end_with_return
blockEndWithReturn :: JITBlock -> Maybe JITLocation -> JITRValue -> IO ()
blockEndWithReturn b l = {#call unsafe gcc_jit_block_end_with_return#} b (fromMaybeLocation l)

-- | gcc_jit_block_end_with_void_return
blockEndWithVoidReturn :: JITBlock -> Maybe JITLocation -> IO ()
blockEndWithVoidReturn b l = {#call unsafe gcc_jit_block_end_with_void_return#} b (fromMaybeLocation l)

#ifdef LIBGCCJIT_HAVE_SWITCH_STATEMENTS
-- | gcc_jit_block_end_with_switch
blockEndWithSwitch :: JITBlock -> Maybe JITLocation -> JITRValue -> JITBlock -> [JITCase] -> IO ()
blockEndWithSwitch b l e db cs = withArray (map extractPointer cs) $ \ar -> {#call unsafe gcc_jit_block_end_with_switch#} b (fromMaybeLocation l) e db (fromIntegral $ length cs) (castPtr ar :: Ptr JITCase)
    where
        extractPointer (JITCase p) = p --JITParam isn't Storable, but the pointer it encapsulates is
#endif

-- The created C bindings are inserted at the end of the file
-- * C functions
