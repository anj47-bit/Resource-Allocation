from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy import Column, BigInteger, String, select
import os

# PostgreSQL connection URL (Replace with your actual DB URL)
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql+asyncpg://aj-47:anuraj314159@localhost:5432/agentlang")

# Create Async Engine and Session
engine = create_async_engine(DATABASE_URL, echo=True)
AsyncSessionLocal = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
Base = declarative_base()

# Define Employee Model
class Employee(Base):
    __tablename__ = "employee"
    email = Column("Email", String, primary_key=True)  # Set Email as Primary Key
    first_name = Column("First Name", String, nullable=True)
    last_name = Column("Last Name", String, nullable=True)
    preferred_name = Column("Preferred Name", String, nullable=True)
    team = Column("Team", String, nullable=True)
    role = Column("Role", String, nullable=True)
    hr_level = Column("HR Level", BigInteger, nullable=True)
    resource_type = Column("Resource Type", String, nullable=True)
    organization = Column("Organization", String, nullable=True)
    hourly_rate = Column("Hourly Rate ($)", BigInteger, nullable=True)
    avg_weekly_hours = Column("Average Weekly Hours", BigInteger, nullable=True)
    annual_rate = Column("Calculated Annual Rate", BigInteger, nullable=True)
    manager_name = Column("Manager Name", String, nullable=True)
    org_tree = Column("Org Tree", String, nullable=True)
    status = Column("Status", String, nullable=True)
    start_date = Column("Start Date", String, nullable=True)
    end_date = Column("End Date", String, nullable=True)
    work_location = Column("Work Location", String, nullable=True)
    location_category = Column("Location Category", String, nullable=True)
    team_2 = Column("Team_2", String, nullable=True)

# Initialize FastAPI app
app = FastAPI()

# Dependency to get DB session
async def get_db():
    async with AsyncSessionLocal() as session:
        yield session

# API to get all employees
@app.get("/api/employees")
async def get_employees(db: AsyncSession = Depends(get_db)):
    query = select(Employee)
    result = await db.execute(query)
    employees = result.scalars().all()
    return employees

# API to fetch a specific employee by email
@app.get("/api/employees/{email}")
async def get_employee(email: str, db: AsyncSession = Depends(get_db)):
    query = select(Employee).where(Employee.email == email)
    result = await db.execute(query)
    employee = result.scalar_one_or_none()
    if not employee:
        raise HTTPException(status_code=404, detail="Employee not found")
    return employee


# Run the application with uvicorn (if running as main script)
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
