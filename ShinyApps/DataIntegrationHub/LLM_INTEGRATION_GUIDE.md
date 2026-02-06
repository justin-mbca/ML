# LLM Integration Guide for Data Integration Hub

## Overview
This Shiny app includes placeholder functions for integrating Large Language Models (LLMs) to analyze clinical documents. Currently, it displays **mock data** for demonstration purposes.

## Quick Start

### Current Status
- ❌ Real LLM integration: **Disabled** (using mock data)
- ✅ UI/Dashboard: **Complete**
- ✅ Placeholder functions: **Ready for implementation**

### To Enable Real LLM Integration
1. Choose an LLM provider (see options below)
2. Update `analyze_document_llm()` function in `app.R`
3. Set `use_real_llm = TRUE` in `process_documents_batch()`
4. Redeploy the app

---

## Integration Options

### Option 1: OpenAI GPT-4 (Recommended for Production)

**Pros:** Best quality, widely supported, good documentation  
**Cons:** Requires API key, costs per token  
**Cost:** ~$0.03-0.06 per 1K tokens

#### Setup Steps:
1. Get API key: https://platform.openai.com/api-keys
2. Install packages:
```r
install.packages(c("httr", "jsonlite"))
```

3. Add to `app.R`:
```r
analyze_document_llm <- function(document_text, api_key = NULL) {
  library(httr)
  library(jsonlite)
  
  if (is.null(api_key)) {
    api_key <- Sys.getenv("OPENAI_API_KEY")
  }
  
  response <- POST(
    url = "https://api.openai.com/v1/chat/completions",
    add_headers(Authorization = paste("Bearer", api_key)),
    body = toJSON(list(
      model = "gpt-4",
      messages = list(list(
        role = "user",
        content = paste(
          "Analyze this clinical document. Return JSON with:",
          "1. sentiment (Positive/Neutral/Negative)",
          "2. key_terms (count)",
          "3. category (Protocol/CSR/SAP/ICF)",
          "\n\nDocument:", document_text
        )
      ))
    ), auto_unbox = TRUE),
    content_type_json()
  )
  
  result <- content(response, "parsed")
  return(result)
}
```

4. Set environment variable (locally):
```r
# In R console or .Renviron file
Sys.setenv(OPENAI_API_KEY = "sk-your-api-key-here")
```

5. For shinyapps.io deployment:
   - Go to Settings → Environment Variables
   - Add: `OPENAI_API_KEY` = `your-key`

---

### Option 2: Anthropic Claude

**Pros:** Strong at long documents, cost-effective  
**Cons:** Requires API key  
**Cost:** ~$0.015-0.075 per 1K tokens

#### Setup:
1. Get API key: https://console.anthropic.com/
2. Install: `install.packages("httr")`
3. Implementation:

```r
analyze_document_llm <- function(document_text, api_key = NULL) {
  library(httr)
  library(jsonlite)
  
  if (is.null(api_key)) {
    api_key <- Sys.getenv("ANTHROPIC_API_KEY")
  }
  
  response <- POST(
    url = "https://api.anthropic.com/v1/messages",
    add_headers(
      "x-api-key" = api_key,
      "anthropic-version" = "2023-06-01",
      "content-type" = "application/json"
    ),
    body = toJSON(list(
      model = "claude-3-sonnet-20240229",
      max_tokens = 1024,
      messages = list(list(
        role = "user",
        content = paste("Analyze this document:", document_text)
      ))
    ), auto_unbox = TRUE)
  )
  
  result <- content(response, "parsed")
  return(result)
}
```

---

### Option 3: Ollama (Local/Free)

**Pros:** Free, private, no API limits  
**Cons:** Requires local setup, slower  
**Cost:** Free (hardware dependent)

#### Setup:
1. Install Ollama: https://ollama.ai/
2. Pull model: `ollama pull llama2` or `ollama pull mistral`
3. Implementation:

```r
analyze_document_llm <- function(document_text) {
  library(httr)
  library(jsonlite)
  
  # Ollama runs locally on port 11434
  response <- POST(
    url = "http://localhost:11434/api/generate",
    body = toJSON(list(
      model = "llama2",
      prompt = paste(
        "Analyze this clinical document and provide:",
        "- Sentiment (Positive/Neutral/Negative)",
        "- Key terms count",
        "- Category (Protocol/CSR/SAP/ICF)",
        "\nDocument:", document_text
      ),
      stream = FALSE
    ), auto_unbox = TRUE),
    content_type_json()
  )
  
  result <- content(response, "parsed")
  return(result)
}
```

**Note:** Ollama won't work on shinyapps.io (cloud), only locally.

---

### Option 4: R Text Analysis (No LLM)

**Pros:** Free, no API, works anywhere  
**Cons:** Limited capabilities, rule-based  

#### Setup:
```r
install.packages(c("tidytext", "textdata", "syuzhet", "topicmodels"))
```

#### Implementation:
```r
analyze_document_r <- function(document_text) {
  library(syuzhet)
  library(tidytext)
  
  # Sentiment analysis
  sentiment_scores <- get_sentiment(document_text, method = "syuzhet")
  sentiment <- if (sentiment_scores > 0) "Positive" 
               else if (sentiment_scores < 0) "Negative" 
               else "Neutral"
  
  # Extract key terms
  words <- unlist(strsplit(tolower(document_text), "\\W+"))
  key_terms <- length(unique(words[nchar(words) > 5]))
  
  # Simple category detection
  category <- if (grepl("protocol|study design", tolower(document_text))) "Protocol"
              else if (grepl("clinical study report|results", tolower(document_text))) "CSR"
              else if (grepl("statistical analysis|analysis plan", tolower(document_text))) "SAP"
              else "ICF"
  
  return(list(
    sentiment = sentiment,
    key_terms = key_terms,
    category = category
  ))
}
```

---

## Implementation Checklist

- [ ] Choose LLM provider
- [ ] Obtain API keys (if needed)
- [ ] Install required R packages
- [ ] Replace `analyze_document_llm()` function
- [ ] Test with sample documents
- [ ] Set `use_real_llm = TRUE`
- [ ] Configure environment variables
- [ ] Add error handling
- [ ] Add rate limiting (for API providers)
- [ ] Test deployment locally
- [ ] Deploy to shinyapps.io

---

## Testing

Test the integration locally before deploying:

```r
# Test analysis function
test_doc <- "This is a clinical study protocol for evaluating drug efficacy in patients with hypertension."
result <- analyze_document_llm(test_doc)
print(result)

# Test in Shiny app
shiny::runApp("ShinyApps/DataIntegrationHub")
```

---

## Deployment Notes

### For shinyapps.io:
1. Add API keys in Settings → Environment Variables
2. Ensure `httr` and `jsonlite` are in your app's dependencies
3. Add rate limiting to avoid exceeding API quotas
4. Monitor usage and costs

### For local deployment:
1. Use `.Renviron` file for API keys
2. Consider Ollama for free local LLM
3. No deployment restrictions

---

## Cost Management

### Estimated Costs (per 1000 documents):
- **OpenAI GPT-4:** ~$30-60 (depending on document length)
- **Anthropic Claude:** ~$15-75
- **Ollama:** Free
- **R packages:** Free

### Tips to Reduce Costs:
1. Use GPT-3.5-turbo instead of GPT-4 (~10x cheaper)
2. Truncate documents to essential sections
3. Batch process during off-peak hours
4. Cache results to avoid re-analyzing same documents
5. Use local models for development/testing

---

## Support

- OpenAI Docs: https://platform.openai.com/docs
- Anthropic Docs: https://docs.anthropic.com/
- Ollama Docs: https://github.com/ollama/ollama
- R tidytext: https://www.tidytextmining.com/

---

## License & Privacy

When using cloud LLM providers:
- Review their data retention policies
- Do NOT send PHI/PII without proper agreements
- Consider HIPAA-compliant options if processing real patient data
- Use de-identified data for demonstrations

For production use with real clinical data:
- Use on-premise/local solutions (Ollama)
- Sign BAAs with cloud providers
- Implement proper data encryption
- Follow 21 CFR Part 11 compliance requirements
