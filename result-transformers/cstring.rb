module RSI::ResultTransformer
  class CString < RSI::ResultTransformer::Transformer
    def to_rust_result
      "std::c_str::CString::new(foreign_result, false)"
    end

    def to_c_result_type
      "*i8"
    end
  end
end