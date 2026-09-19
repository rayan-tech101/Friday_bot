import os
import requests
import google.generativeai as genai

# Configure Gemini
genai.configure(api_key=os.environ["GEMINI_API_KEY"])

# Sub-Agent 1: Tactical Researcher
def agent_researcher(prompt):
    model = genai.GenerativeModel('gemini-2.5-flash')
    sys_instruction = "You are F.R.I.D.A.Y.'s Tactical Researcher. Analyze data concisely without conversational filler."
    response = model.generate_content(f"{sys_instruction}\n\nTask: {prompt}")
    return response.text

# Orchestrator: F.R.I.D.A.Y. Core
def agent_friday_core(user_message):
    model = genai.GenerativeModel('gemini-2.5-flash')
    
    # Check if task requires delegation
    if "research" in user_message.lower() or "find" in user_message.lower():
        research_results = agent_researcher(user_message)
        prompt = f"You are F.R.I.D.A.Y., a loyal tactical AI assistant. Summarize these research findings for the boss: {research_results}"
    else:
        prompt = f"You are F.R.I.D.A.Y., an advanced AI assistant. Answer concisely and professionally: {user_message}"
        
    response = model.generate_content(prompt)
    return response.text

# Telegram Polling Loop
def run_bot():
    token = os.environ["TELEGRAM_BOT_TOKEN"]
    url = f"https://api.telegram.org/bot{token}/"
    offset = 0
    
    # Process messages
    updates = requests.get(url + f"getUpdates?offset={offset}").json()
    if "result" in updates and len(updates["result"]) > 0:
        for update in updates["result"]:
            offset = update["update_id"] + 1
            chat_id = update["message"]["chat"]["id"]
            text = update["message"].get("text", "")
            
            # Generate Multi-Agent Response
            reply = agent_friday_core(text)
            
            # Send message back to iPhone
            requests.post(url + "sendMessage", data={"chat_id": chat_id, "text": reply})

if __name__ == "__main__":
    run_bot()
